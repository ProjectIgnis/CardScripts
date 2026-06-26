Chain={}

local CARD_PROPERTIES = {
	"Code",
	"Controler",
	"Location",
	"Sequence",
	"Position",
	"Type",
	"Level",
	"Rank",
	"Scale",
	"Link",
	"Attribute",
	"Race",
	"Attack",
	"Defense",
	"SummonLocation",
	"SummonType",
	"SetCard"
}

local function get_all_current_properties(c)
	local t={}
	for _,prop in ipairs(CARD_PROPERTIES) do
		local fn=Card["Get"..prop]
		if prop=="Code" or prop=="SetCard" then
			t[prop]={fn(c)}
		else
			t[prop]=fn(c)
		end
	end
	return t
end

--[[
	A mechanism for saving any amount of custom values that are strictly associated to a specific Chain Link.
--]]

local data_table={}

local function register_data_reset_effect()
	-- clear data table at the end of chain resolution
	local data_reset=Effect.GlobalEffect()
	data_reset:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	data_reset:SetCode(EVENT_CHAIN_END)
	data_reset:SetCountLimit(1)
	data_reset:SetOperation(function() data_table={} end)
	Duel.RegisterEffect(data_reset,0)
end

local shared_data_key={} -- dummy table to be used as a unique key

function Chain.Data(ch,key)
	local current_link=Chain.GetCurrentLink()
	if current_link==0 then
		return error("Attempted to access Chain Data table while there is currently no Chain",2)
	elseif ch and ch>current_link then
		return error("Attempted to access Chain Link higher than current Chain",2)
	end

	if not ch or ch==0 then ch=current_link end

	local cid=Chain.GetID(ch)
	local chain_link_data=data_table[cid] or {}
	data_table[cid]=chain_link_data

	-- if no key is supplied, use the default key to access shared data table
	key=key or shared_data_key

	chain_link_data[key]=chain_link_data[key] or {}
	return chain_link_data[key]
end

function Effect.GetChainData(e,ch)
	return Chain.Data(ch,e)
end

--[[
	Duel.GetChainInfo split into individual functions.
--]]

local function chaininfo_fn(info)
	return function(ch)
		return Duel.GetChainInfo(ch or 0,info)
	end
end

Chain.GetTargetCards   = chaininfo_fn(CHAININFO_TARGET_CARDS)
Chain.GetTargetPlayer  = chaininfo_fn(CHAININFO_TARGET_PLAYER)
Chain.GetTargetParam   = chaininfo_fn(CHAININFO_TARGET_PARAM)
Chain.GetDisableReason = chaininfo_fn(CHAININFO_DISABLE_REASON)
Chain.GetDisablePlayer = chaininfo_fn(CHAININFO_DISABLE_PLAYER)
Chain.GetID            = chaininfo_fn(CHAININFO_CHAIN_ID)

Chain.GetTriggeringEffect           = chaininfo_fn(CHAININFO_TRIGGERING_EFFECT)
Chain.GetTriggeringPlayer           = chaininfo_fn(CHAININFO_TRIGGERING_PLAYER)
Chain.GetTriggeringControler        = chaininfo_fn(CHAININFO_TRIGGERING_CONTROLER)
Chain.GetTriggeringLocation         = chaininfo_fn(CHAININFO_TRIGGERING_LOCATION)
Chain.GetTriggeringLocationSymbolic = chaininfo_fn(CHAININFO_TRIGGERING_LOCATION_SYMBOLIC)
Chain.GetTriggeringSequence         = chaininfo_fn(CHAININFO_TRIGGERING_SEQUENCE)
Chain.GetTriggeringSequenceSymbolic = chaininfo_fn(CHAININFO_TRIGGERING_SEQUENCE_SYMBOLIC)
Chain.GetTriggeringPosition         = chaininfo_fn(CHAININFO_TRIGGERING_POSITION)
Chain.GetTriggeringType             = chaininfo_fn(CHAININFO_TRIGGERING_TYPE)
Chain.GetTriggeringLevel            = chaininfo_fn(CHAININFO_TRIGGERING_LEVEL)
Chain.GetTriggeringRank             = chaininfo_fn(CHAININFO_TRIGGERING_RANK)
Chain.GetTriggeringScale            = chaininfo_fn(CHAININFO_TRIGGERING_LSCALE) --assume Left and Right Scales are the same
Chain.GetTriggeringLink             = chaininfo_fn(CHAININFO_TRIGGERING_LINK)
Chain.GetTriggeringAttribute        = chaininfo_fn(CHAININFO_TRIGGERING_ATTRIBUTE)
Chain.GetTriggeringRace             = chaininfo_fn(CHAININFO_TRIGGERING_RACE)
Chain.GetTriggeringATK              = chaininfo_fn(CHAININFO_TRIGGERING_ATTACK)
Chain.GetTriggeringDEF              = chaininfo_fn(CHAININFO_TRIGGERING_DEFENSE)
Chain.GetTriggeringStatus           = chaininfo_fn(CHAININFO_TRIGGERING_STATUS)
Chain.GetTriggeringSummonLocation   = chaininfo_fn(CHAININFO_TRIGGERING_SUMMON_LOCATION)
Chain.GetTriggeringSummonType       = chaininfo_fn(CHAININFO_TRIGGERING_SUMMON_TYPE)
Chain.GetTriggeringSetcode          = chaininfo_fn(CHAININFO_TRIGGERING_SETCODES)

Chain.IsTriggeringCardProperlySummoned = chaininfo_fn(CHAININFO_TRIGGERING_SUMMON_PROC_COMPLETE)

function Chain.GetTriggeringCode(ch)
	return Duel.GetChainInfo(ch or 0,CHAININFO_TRIGGERING_CODE,CHAININFO_TRIGGERING_CODE2)
end

function Chain.GetTriggeringSetcode(ch)
	local trig_setcodes=Duel.GetChainInfo(ch or 0,CHAININFO_TRIGGERING_SETCODES)
	if trig_setcodes==nil then return nil end
	return table.unpack(trig_setcodes)
end

local function get_all_triggering_properties(ch)
	local t={}
	for _,prop in ipairs(CARD_PROPERTIES) do
		local fn=Chain["GetTriggering"..prop]
		if prop=="Code" or prop=="SetCard" then
			t[prop]={fn(ch)}
		else
			t[prop]=fn(ch)
		end
	end
	return t
end

--[[
	Boolean check versions for the above ChainInfo functions.
--]]

local function return_equals(fn)
	return function(ch,val)
		local res=fn(ch)
		if res==nil then return nil end
		return res==val
	end
end

local function return_has_common_bits(fn)
	return function(ch,val)
		local res=fn(ch)
		if res==nil then return nil end
		return (res&val)>0
	end
end

local function return_equals_any(fn)
	return function(ch,...)
		local res=fn(ch)
		if res==nil then return nil end
		for _,val in ipairs({...}) do
			if res==val then return true end
		end
		return false
	end
end

Chain.IsDisablePlayer            = return_equals          (Chain.GetDisablePlayer)
Chain.IsTriggeringEffect         = return_equals          (Chain.GetTriggeringEffect)
Chain.IsTriggeringPlayer         = return_equals          (Chain.GetTriggeringPlayer)
Chain.IsTriggeringControler      = return_equals          (Chain.GetTriggeringControler)
Chain.IsTriggeringSequence       = return_equals_any      (Chain.GetTriggeringSequence)
Chain.IsTriggeringPosition       = return_has_common_bits (Chain.GetTriggeringPosition)
Chain.IsTriggeringType           = return_has_common_bits (Chain.GetTriggeringType)
Chain.IsTriggeringLevel          = return_equals_any      (Chain.GetTriggeringLevel)
Chain.IsTriggeringRank           = return_equals_any      (Chain.GetTriggeringRank)
Chain.IsTriggeringScale          = return_equals_any      (Chain.GetTriggeringScale)
Chain.IsTriggeringLink           = return_equals_any      (Chain.GetTriggeringLink)
Chain.IsTriggeringAttribute      = return_has_common_bits (Chain.GetTriggeringAttribute)
Chain.IsTriggeringRace           = return_has_common_bits (Chain.GetTriggeringRace)
Chain.IsTriggeringATK            = return_equals_any      (Chain.GetTriggeringATK)
Chain.IsTriggeringDEF            = return_equals_any      (Chain.GetTriggeringDEF)
Chain.IsTriggeringStatus         = return_has_common_bits (Chain.GetTriggeringStatus)
Chain.IsTriggeringSummonLocation = return_has_common_bits (Chain.GetTriggeringSummonLocation)
Chain.IsTriggeringSummonType     = return_has_common_bits (Chain.GetTriggeringSummonType)

local function code_check(codes,...)
	if codes==nil then return nil end
	for _,code in ipairs({...}) do
		if code==codes[1] or code==codes[2] then return true end
	end
	return false
end

function Chain.IsTriggeringCode(ch,...)
	local trig_code_1,trig_code_2=Chain.GetTriggeringCode(ch)
	if trig_code_1==nil then return nil end
	return code_check({trig_code_1,trig_code_2},...)
end

--integrates symbolic locations to be consistent with Card.IsLocation
Chain.IsTriggeringLocation = aux.OR(
	return_has_common_bits(Chain.GetTriggeringLocation),
	return_has_common_bits(Chain.GetTriggeringLocationSymbolic)
)

local function setcode_check(setcodes_to_match,setcodes)
	if setcodes_to_match==nil then return nil end
	if type(setcodes)=="number" then setcodes={setcodes} end
	for _,sa in ipairs(setcodes_to_match) do
		for _,sb in ipairs(setcodes) do
			if (sa&0xfff)==(sb&0xfff) and (sa&sb)==sb then return true end
		end
	end
	return false
end

function Chain.IsTriggeringSetcode(ch,setcodes)
	--should not use Chain.GetTriggeringSetcode here because it unpacks the table (to be consistent with Card.GetSetCard),
	--making it impossible to tell if there is no triggering property, or the card just happened to not have setcodes
	local trig_setcodes=Duel.GetChainInfo(ch or 0,CHAININFO_TRIGGERING_SETCODES)
	if trig_setcodes==nil then return nil end
	return setcode_check(trig_setcodes,setcodes)
end

function Chain.IsTriggeringRaceExcept(ch,race)
	return Chain.IsTriggeringRace(ch,RACE_ALL&~race)
end

function Chain.IsTriggeringAttributeExcept(ch,attr)
	return Chain.IsTriggeringAttribute(ch,ATTRIBUTE_ALL&~attr)
end

function Chain.IsTriggeringCompositeType(ch,typ)
	local trig_typ=Chain.GetTriggeringType(ch)
	if trig_typ==nil then return nil end
	return (trig_typ&typ)==typ
end

Chain.IsTriggeringExactType = return_equals(Chain.GetTriggeringType)

Chain.GetTriggeringAttack           = Chain.GetTriggeringATK
Chain.GetTriggeringDefense          = Chain.GetTriggeringDEF
Chain.GetTriggeringSetCard          = Chain.GetTriggeringSetcode
Chain.IsTriggeringAttack            = Chain.IsTriggeringATK
Chain.IsTriggeringDefense           = Chain.IsTriggeringDEF
Chain.IsTriggeringSetCard           = Chain.IsTriggeringSetcode

--[[
	Storing card properties at the start of effect resolution.
--]]

local function register_resolving_props_effect()
	-- store the resolving card's properties
	local store_resolving_props=Effect.GlobalEffect()
	store_resolving_props:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	store_resolving_props:SetCode(EVENT_CHAIN_SOLVING)
	store_resolving_props:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local rc=re:GetHandler()
		if rc:IsRelateToEffect(re) then
			Chain.Data().resolving_properties=get_all_current_properties(rc)
		end
	end)
	Duel.RegisterEffect(store_resolving_props,0)
end

local function get_all_resolving_properties(ch)
	return Chain.Data(ch).resolving_properties
end

local resolving_fns={}

for _,prop in ipairs(CARD_PROPERTIES) do
	resolving_fns["Get"..prop] = function(ch)
		local res_props=Chain.Data(ch).resolving_properties
		if not res_props then return end
		if prop=="Code" or prop=="SetCard" then
			return table.unpack(res_props[prop])
		end
		return res_props[prop]
	end
end

resolving_fns.IsControler      = return_equals          (resolving_fns.GetControler)
resolving_fns.IsSequence       = return_equals_any      (resolving_fns.GetSequence)
resolving_fns.IsPosition       = return_has_common_bits (resolving_fns.GetPosition)
resolving_fns.IsType           = return_has_common_bits (resolving_fns.GetType)
resolving_fns.IsLevel          = return_equals_any      (resolving_fns.GetLevel)
resolving_fns.IsRank           = return_equals_any      (resolving_fns.GetRank)
resolving_fns.IsScale          = return_equals_any      (resolving_fns.GetScale)
resolving_fns.IsLink           = return_equals_any      (resolving_fns.GetLink)
resolving_fns.IsAttribute      = return_has_common_bits (resolving_fns.GetAttribute)
resolving_fns.IsRace           = return_has_common_bits (resolving_fns.GetRace)
resolving_fns.IsAttack         = return_equals_any      (resolving_fns.GetAttack)
resolving_fns.IsDefense        = return_equals_any      (resolving_fns.GetDefense)
resolving_fns.IsStatus         = return_has_common_bits (resolving_fns.GetStatus)
resolving_fns.IsSummonLocation = return_has_common_bits (resolving_fns.GetSummonLocation)
resolving_fns.IsSummonType     = return_has_common_bits (resolving_fns.GetSummonType)

function resolving_fns.IsCode(ch,...)
	local res_props=Chain.Data(ch).resolving_properties
	if res_props==nil then return nil end
	return code_check(res_props.Code,...)
end

function resolving_fns.IsSetCard(ch,setcodes)
	local res_props=Chain.Data(ch).resolving_properties
	if res_props==nil then return nil end
	return setcode_check(res_props.SetCard,setcodes)
end

--[[
	Table and functions for storing/checking the properties of a card at the time it registers an effect.
	Needs to be defined here to make them visible to the functions that need them.
	(The actual tracking logic is implemented further below, since it relies on a function that is defined later)
--]]

local registering_properties={}

local function get_all_registering_properties(e)
	return registering_properties[tostring(e)]
end

local registering_fns={}

for _,prop in ipairs(CARD_PROPERTIES) do
	registering_fns["Get"..prop] = function(e)
		local reg_props=registering_properties[tostring(e)]
		if prop=="Code" or prop=="SetCard" then
			return table.unpack(reg_props[prop])
		end
		return reg_props[prop]
	end
end

registering_fns.IsControler      = return_equals          (registering_fns.GetControler)
registering_fns.IsSequence       = return_equals_any      (registering_fns.GetSequence)
registering_fns.IsPosition       = return_has_common_bits (registering_fns.GetPosition)
registering_fns.IsType           = return_has_common_bits (registering_fns.GetType)
registering_fns.IsLevel          = return_equals_any      (registering_fns.GetLevel)
registering_fns.IsRank           = return_equals_any      (registering_fns.GetRank)
registering_fns.IsScale          = return_equals_any      (registering_fns.GetScale)
registering_fns.IsLink           = return_equals_any      (registering_fns.GetLink)
registering_fns.IsAttribute      = return_has_common_bits (registering_fns.GetAttribute)
registering_fns.IsRace           = return_has_common_bits (registering_fns.GetRace)
registering_fns.IsAttack         = return_equals_any      (registering_fns.GetAttack)
registering_fns.IsDefense        = return_equals_any      (registering_fns.GetDefense)
registering_fns.IsStatus         = return_has_common_bits (registering_fns.GetStatus)
registering_fns.IsSummonLocation = return_has_common_bits (registering_fns.GetSummonLocation)
registering_fns.IsSummonType     = return_has_common_bits (registering_fns.GetSummonType)

function registering_fns.IsCode(e,...)
	local reg_props=registering_properties[tostring(e)]
	if reg_props==nil then return nil end
	return code_check(reg_props.Code,...)
end

function registering_fns.IsSetCard(e,setcodes)
	local reg_props=registering_properties[tostring(e)]
	if reg_props==nil then return nil end
	return setcode_check(reg_props.SetCard,setcodes)
end

--[[
	Dynamic chain properties:
		* Current properties if the card is still the same copy and face-up.
		* Resolving properties if the card was still the same copy at the start of resolution but no longer is.
		* Triggering properties if the card was no longer the same copy at the start of resolution.
		* Registering Properties if the effect is a Duel effect.
--]]

local function chain_prop(mode)
	return function(prop)
		local triggering_fn = Chain[mode.."Triggering"..prop] or get_all_triggering_properties
		local resolving_fn = resolving_fns[mode..prop] or get_all_resolving_properties
		local registering_fn = registering_fns[mode..prop] or get_all_registering_properties
		return function(ch,...)
			if Chain.GetCurrentLink()==0 then return end
			local eff=Chain.GetTriggeringEffect(ch)

			if eff:IsHasProperty(EFFECT_FLAG_FIELD_ONLY) then
				return registering_fn(eff,...)
			end

			local ec=eff:GetHandler()
			if ec:IsRelateToEffect(eff) and ec:IsFaceup() then
				--retrieve current_fn as late as possible, since it could be overwritten in other utility files
				local current_fn = Card[mode..prop] or get_all_current_properties
				return current_fn(ec,...)
			end

			local res=resolving_fn(ch,...)
			if res~=nil then return res end
			return triggering_fn(ch,...)
		end
	end
end

local get_chain_prop = chain_prop("Get")
local get_all_chain_properties = get_chain_prop("")

Chain.GetCode           = get_chain_prop("Code")
Chain.GetControler      = get_chain_prop("Controler")
Chain.GetLocation       = get_chain_prop("Location")
Chain.GetSequence       = get_chain_prop("Sequence")
Chain.GetPosition       = get_chain_prop("Position")
Chain.GetType           = get_chain_prop("Type")
Chain.GetLevel          = get_chain_prop("Level")
Chain.GetRank           = get_chain_prop("Rank")
Chain.GetScale          = get_chain_prop("Scale")
Chain.GetLink           = get_chain_prop("Link")
Chain.GetAttribute      = get_chain_prop("Attribute")
Chain.GetRace           = get_chain_prop("Race")
Chain.GetATK            = get_chain_prop("Attack")
Chain.GetDEF            = get_chain_prop("Defense")
Chain.GetSummonLocation = get_chain_prop("SummonLocation")
Chain.GetSummonType     = get_chain_prop("SummonType")
Chain.GetSetcode        = get_chain_prop("SetCard")

local is_chain_prop = chain_prop("Is")

Chain.IsCode           = is_chain_prop("Code")
Chain.IsControler      = is_chain_prop("Controler")
Chain.IsLocation       = is_chain_prop("Location")
Chain.IsSequence       = is_chain_prop("Sequence")
Chain.IsPosition       = is_chain_prop("Position")
Chain.IsType           = is_chain_prop("Type")
Chain.IsLevel          = is_chain_prop("Level")
Chain.IsRank           = is_chain_prop("Rank")
Chain.IsScale          = is_chain_prop("Scale")
Chain.IsLink           = is_chain_prop("Link")
Chain.IsAttribute      = is_chain_prop("Attribute")
Chain.IsRace           = is_chain_prop("Race")
Chain.IsATK            = is_chain_prop("Attack")
Chain.IsDEF            = is_chain_prop("Defense")
Chain.IsSummonLocation = is_chain_prop("SummonLocation")
Chain.IsSummonType     = is_chain_prop("SummonType")
Chain.IsSetcode        = is_chain_prop("SetCard")

function Chain.IsRaceExcept(ch,race)
	return Chain.IsRace(ch,RACE_ALL&~race)
end

function Chain.IsAttributeExcept(ch,attr)
	return Chain.IsAttribute(ch,ATTRIBUTE_ALL&~attr)
end

function Chain.IsCompositeType(ch,typ)
	local ch_typ=Chain.GetType(ch)
	if ch_typ==nil then return nil end
	return (ch_typ&typ)==typ
end

Chain.IsExactType = return_equals(Chain.GetType)

Chain.GetAttack           = Chain.GetATK
Chain.GetDefense          = Chain.GetDEF
Chain.GetSetCard          = Chain.GetSetcode
Chain.IsAttack            = Chain.IsATK
Chain.IsDefense           = Chain.IsDEF
Chain.IsSetCard           = Chain.IsSetcode

--[[
	Dynamic effect properties:
		* Registering properties if it's a Duel effect.
		* Dynamic Chain properties as defined above if it's an activated effect that is currently triggering/resolving.
		* Current properties if it's a non-activated effect.
		* Can later add implementation for continuous effects that apply at specific timings
			(needs tracking card properties when the effect starts applying)
--]]

local function effect_card_prop(mode)
	return function(prop)
		local registering_fn = registering_fns[mode..prop] or get_all_registering_properties
		local chain_fn = Chain[mode..prop] or get_all_chain_properties
		return function(e,...)
			if e:IsHasProperty(EFFECT_FLAG_FIELD_ONLY) then
				if e:IsGlobalEffect() then
					return (mode=="Is") and false or nil
				end
				return registering_fn(e,...)
			end
			--retrieve current_fn as late as possible, since it could be overwritten in other utility files
			local current_fn = Card[mode..prop] or get_all_current_properties
			if not e:IsActivated() then
				return current_fn(e:GetOwner(),...)
			end
			if Chain.IsTriggeringEffect(0,e) then
				return chain_fn(0,...)
			end
			--default to current properties
			return current_fn(e:GetOwner(),...)
		end
	end
end

local effect_get_card_prop = effect_card_prop("Get")
local effect_get_all_card_props = effect_get_card_prop("")

Effect.GetCardCode           = effect_get_card_prop("Code")
Effect.GetCardControler      = effect_get_card_prop("Controler")
Effect.GetCardLocation       = effect_get_card_prop("Location")
Effect.GetCardSequence       = effect_get_card_prop("Sequence")
Effect.GetCardPosition       = effect_get_card_prop("Position")
Effect.GetCardType           = effect_get_card_prop("Type")
Effect.GetCardLevel          = effect_get_card_prop("Level")
Effect.GetCardRank           = effect_get_card_prop("Rank")
Effect.GetCardScale          = effect_get_card_prop("Scale")
Effect.GetCardLink           = effect_get_card_prop("Link")
Effect.GetCardAttribute      = effect_get_card_prop("Attribute")
Effect.GetCardRace           = effect_get_card_prop("Race")
Effect.GetCardATK            = effect_get_card_prop("Attack")
Effect.GetCardDEF            = effect_get_card_prop("Defense")
Effect.GetCardSummonLocation = effect_get_card_prop("SummonLocation")
Effect.GetCardSummonType     = effect_get_card_prop("SummonType")
Effect.GetCardSetcode        = effect_get_card_prop("SetCard")

local effect_is_card_prop = effect_card_prop("Is")

Effect.IsCardCode           = effect_is_card_prop("Code")
Effect.IsCardControler      = effect_is_card_prop("Controler")
Effect.IsCardLocation       = effect_is_card_prop("Location")
Effect.IsCardSequence       = effect_is_card_prop("Sequence")
Effect.IsCardPosition       = effect_is_card_prop("Position")
Effect.IsCardType           = effect_is_card_prop("Type")
Effect.IsCardLevel          = effect_is_card_prop("Level")
Effect.IsCardRank           = effect_is_card_prop("Rank")
Effect.IsCardScale          = effect_is_card_prop("Scale")
Effect.IsCardLink           = effect_is_card_prop("Link")
Effect.IsCardAttribute      = effect_is_card_prop("Attribute")
Effect.IsCardRace           = effect_is_card_prop("Race")
Effect.IsCardATK            = effect_is_card_prop("Attack")
Effect.IsCardDEF            = effect_is_card_prop("Defense")
Effect.IsCardSummonLocation = effect_is_card_prop("SummonLocation")
Effect.IsCardSummonType     = effect_is_card_prop("SummonType")
Effect.IsCardSetcode        = effect_is_card_prop("SetCard")

function Effect.IsCardRaceExcept(e,race)
	return e:IsCardRace(RACE_ALL&~race)
end

function Effect.IsCardAttributeExcept(e,attr)
	return e:IsCardAttribute(ATTRIBUTE_ALL&~attr)
end

function Effect.IsCardCompositeType(e,typ)
	return (e:GetCardType()&typ)==typ
end

function Effect.IsCardExactType(e,typ)
	return e:GetCardType()==typ
end

Effect.GetCardAttack  = Effect.GetCardATK
Effect.GetCardDefense = Effect.GetCardDEF
Effect.GetCardSetCard = Effect.GetCardSetcode
Effect.IsCardAttack   = Effect.IsCardATK
Effect.IsCardDefense  = Effect.IsCardDEF
Effect.IsCardSetCard  = Effect.IsCardSetcode

--[[
	Tracking implementation for storing properties of a card at the time it registers an effect.
	Needs to be defined here to since it needs `effect_get_all_card_props` to be defined first.
--]]

do
	local oldfunc=Duel.RegisterEffect
	function Duel.RegisterEffect(e,player,...)
		local registering_effect=Duel.GetReasonEffect()
		if registering_effect and not e:IsGlobalEffect() then
			registering_properties[tostring(e)]=effect_get_all_card_props(registering_effect)
		end
		oldfunc(e,player,...)
	  end
end


--[[
	Aliases for existing chain-related functions.
	These should eventually become the main names.
--]]

Chain.ChangeOperation	 = Duel.ChangeChainOperation
Chain.CanTarget			 = Duel.CheckChainTarget
Chain.HasUniqueCardNames = Duel.CheckChainUniqueness
Chain.GetCurrentLink	 = Duel.GetCurrentChain
Chain.IsDisablable		 = Duel.IsChainDisablable
Chain.IsNegatable		 = Duel.IsChainNegatable
Chain.IsResolving		 = Duel.IsChainSolving
Chain.SetLimit			 = Duel.SetChainLimit
Chain.SetLimitTillEnd	 = Duel.SetChainLimitTillChainEnd

--[[
	Prevent Debug.ReloadFieldBegin from resetting registered global effects.
--]]

do
	local old=Debug.ReloadFieldBegin
	function Debug.ReloadFieldBegin(...)
		old(...)
		register_data_reset_effect()
		register_resolving_props_effect()
	end
end
