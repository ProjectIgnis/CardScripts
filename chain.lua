Chain={}

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
Chain.GetTriggeringLocationSymbolic = chaininfo_fn(CHAININFO_TRIGGERING_SEQUENCE_SYMBOLIC)
Chain.GetTriggeringPosition         = chaininfo_fn(CHAININFO_TRIGGERING_POSITION)
Chain.GetTriggeringType             = chaininfo_fn(CHAININFO_TRIGGERING_TYPE)
Chain.GetTriggeringLevel            = chaininfo_fn(CHAININFO_TRIGGERING_LEVEL)
Chain.GetTriggeringRank             = chaininfo_fn(CHAININFO_TRIGGERING_RANK)
Chain.GetTriggeringAttribute        = chaininfo_fn(CHAININFO_TRIGGERING_ATTRIBUTE)
Chain.GetTriggeringRace             = chaininfo_fn(CHAININFO_TRIGGERING_RACE)
Chain.GetTriggeringATK              = chaininfo_fn(CHAININFO_TRIGGERING_ATTACK)
Chain.GetTriggeringDEF              = chaininfo_fn(CHAININFO_TRIGGERING_DEFENSE)
Chain.GetTriggeringStatus           = chaininfo_fn(CHAININFO_TRIGGERING_STATUS)
Chain.GetTriggeringSummonLocation   = chaininfo_fn(CHAININFO_TRIGGERING_SUMMON_LOCATION)
Chain.GetTriggeringSummonType       = chaininfo_fn(CHAININFO_TRIGGERING_SUMMON_TYPE)
Chain.GetTriggeringSetcodes         = chaininfo_fn(CHAININFO_TRIGGERING_SETCODES)

Chain.IsTriggeringCardProperlySummoned = chaininfo_fn(CHAININFO_TRIGGERING_SUMMON_PROC_COMPLETE)

function Chain.GetTriggeringCode(ch)
	return Duel.GetChainInfo(ch or 0,CHAININFO_TRIGGERING_CODE,CHAININFO_TRIGGERING_CODE2)
end

-- boolean check versions for chain info functions

local function chaininfo_equals(fn)
	return function(ch,val)
		return fn(ch)==val
	end
end

Chain.IsTriggeringEffect     = chaininfo_equals(Chain.GetTriggeringEffect)
Chain.IsTriggeringPlayer     = chaininfo_equals(Chain.GetTriggeringPlayer)
Chain.IsDisablePlayer        = chaininfo_equals(Chain.GetDisablePlayer)
Chain.IsTriggeringControler  = chaininfo_equals(Chain.GetTriggeringControler)
Chain.IsTriggeringATK        = chaininfo_equals(Chain.GetTriggeringATK)
Chain.IsTriggeringDEF        = chaininfo_equals(Chain.GetTriggeringDEF)

local function chaininfo_includes_bits(fn)
	return function(ch,val)
		local res=fn(ch)
		return res and (res&val)>0
	end
end

Chain.IsTriggeringPosition       = chaininfo_includes_bits(Chain.GetTriggeringPosition)
Chain.IsTriggeringType           = chaininfo_includes_bits(Chain.GetTriggeringType)
Chain.IsTriggeringAttribute	     = chaininfo_includes_bits(Chain.GetTriggeringAttribute)
Chain.IsTriggeringRace	         = chaininfo_includes_bits(Chain.GetTriggeringRace)
Chain.IsTriggeringStatus         = chaininfo_includes_bits(Chain.GetTriggeringStatus)
Chain.IsTriggeringSummonLocation = chaininfo_includes_bits(Chain.GetTriggeringSummonLocation)
Chain.IsTriggeringSummonType     = chaininfo_includes_bits(Chain.GetTriggeringSummonType)

--integrates symbolic locations to be consistent with Card.IsLocation
Chain.IsTriggeringLocation = aux.OR(
	chaininfo_includes_bits(Chain.GetTriggeringLocation),
	chaininfo_includes_bits(Chain.GetTriggeringLocationSymbolic)
)

local function chaininfo_equals_any(fn)
	return function(ch,...)
		local res=fn(ch)
		for _,val in ipairs({...}) do
			if res==val then return true end
		end
		return false
	end
end

Chain.IsTriggeringSequence = chaininfo_equals_any(Chain.GetTriggeringSequence)
Chain.IsTriggeringLevel	   = chaininfo_equals_any(Chain.GetTriggeringLevel)
Chain.IsTriggeringRank	   = chaininfo_equals_any(Chain.GetTriggeringRank)

function Chain.IsTriggeringCode(ch,...)
	local code1,code2=Chain.GetTriggeringCode(ch)
	for _,code in ipairs({...}) do
		if code==code1 or code==code2 then return true end
	end
	return false
end

function Chain.IsTriggeringSetcode(ch,setcodes)
	local trig_setcodes=Chain.GetTriggeringSetcodes(ch)
	if not trig_setcodes then return false end
	if type(setcodes)=="number" then
		setcodes={setcodes}
	end
	for _,setcode in ipairs(setcodes) do
		for _,trig_setcode in ipairs(trig_setcodes) do
			if (setcode&0xfff)==(trig_setcode&0xfff) and (setcode&trig_setcode)==setcode then return true end
		end
	end
	return false
end

function Chain.IsTriggeringRaceExcept(ch,race)
	return Chain.IsTriggeringRace(ch,RACE_ALL&~race)
end

function Chain.IsTriggeringAttributeExcept(ch,attr)
	return Chain.IsTriggeringAttribute(ch,ATTRIBUTE_ALL&~attr)
end

-- dynamic chain properties (current properties if the card is still the same copy, otherwise triggering properties)
local function chain_prop(current_fn,triggering_fn)
	-- this is counting on the assumption that the additional parameters of the `current_fn` functions
	-- won't cause errors with the `triggering_fn` functions, e.g., `Card.GetRace` vs `Chain.GetTriggeringRace`
	return function(ch,...)
		local eff=Chain.GetTriggeringEffect(ch)
		local ec=eff:GetHandler()
		if ec:IsRelateToEffect(eff) and ec:IsFaceup() then
			return current_fn(ec,...)
		end
		return triggering_fn(ch,...)
	end
end

Chain.GetControler      = chain_prop(Card.GetControler,      Chain.GetTriggeringControler)
Chain.GetLocation       = chain_prop(Card.GetLocation,       Chain.GetTriggeringLocation)
Chain.GetSequence       = chain_prop(Card.GetSequence,       Chain.GetTriggeringSequence)
Chain.GetPosition       = chain_prop(Card.GetPosition,       Chain.GetTriggeringPosition)
Chain.GetCode           = chain_prop(Card.GetCode,           Chain.GetTriggeringCode)
Chain.GetType           = chain_prop(Card.GetType,           Chain.GetTriggeringType)
Chain.GetLevel          = chain_prop(Card.GetLevel,          Chain.GetTriggeringLevel)
Chain.GetRank           = chain_prop(Card.GetRank,           Chain.GetTriggeringRank)
Chain.GetAttribute      = chain_prop(Card.GetAttribute,      Chain.GetTriggeringAttribute)
Chain.GetRace           = chain_prop(Card.GetRace,           Chain.GetTriggeringRace)
Chain.GetATK            = chain_prop(Card.GetAttack,         Chain.GetTriggeringATK)
Chain.GetDEF            = chain_prop(Card.GetDefense,        Chain.GetTriggeringDEF)
Chain.GetSummonLocation = chain_prop(Card.GetSummonLocation, Chain.GetTriggeringSummonLocation)
Chain.GetSummonType     = chain_prop(Card.GetSummonType,     Chain.GetTriggeringSummonType)
Chain.GetSetcodes       = chain_prop(Card.GetSetCard,        Chain.GetTriggeringSetcodes)

Chain.IsControler      = chain_prop(Card.IsControler,      Chain.IsTriggeringControler)
Chain.IsLocation       = chain_prop(Card.IsLocation,       Chain.IsTriggeringLocation)
Chain.IsSequence       = chain_prop(Card.IsSequence,       Chain.IsTriggeringSequence)
Chain.IsPosition       = chain_prop(Card.IsPosition,       Chain.IsTriggeringPosition)
Chain.IsCode           = chain_prop(Card.IsCode,           Chain.IsTriggeringCode)
Chain.IsType           = chain_prop(Card.IsType,           Chain.IsTriggeringType)
Chain.IsLevel          = chain_prop(Card.IsLevel,          Chain.IsTriggeringLevel)
Chain.IsRank           = chain_prop(Card.IsRank,           Chain.IsTriggeringRank)
Chain.IsAttribute      = chain_prop(Card.IsAttribute,      Chain.IsTriggeringAttribute)
Chain.IsRace           = chain_prop(Card.IsRace,           Chain.IsTriggeringRace)
Chain.IsATK            = chain_prop(Card.IsAttack,         Chain.IsTriggeringATK)
Chain.IsDEF            = chain_prop(Card.IsDefense,        Chain.IsTriggeringDEF)
Chain.IsSummonLocation = chain_prop(Card.IsSummonLocation, Chain.IsTriggeringSummonLocation)
Chain.IsSummonType     = chain_prop(Card.IsSummonType,     Chain.IsTriggeringSummonType)
Chain.IsSetcode        = chain_prop(Card.IsSetCard,        Chain.IsTriggeringSetcode)

function Chain.IsRaceExcept(ch,race)
	return Chain.IsRace(ch,RACE_ALL&~race)
end

function Chain.IsAttributeExcept(ch,attr)
	return Chain.IsAttribute(ch,ATTRIBUTE_ALL&~attr)
end

-- a mechanism for saving any amount of custom information that is strictly associated to a specific chain link
local info_table={}
local info_reset=Effect.GlobalEffect()
info_reset:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
info_reset:SetCode(EVENT_CHAIN_END)
info_reset:SetOperation(function() info_table={} end)
Duel.RegisterEffect(info_reset,0)

function Chain.Info(ch)
	local cid=Chain.GetID(ch)
	info_table[cid]=info_table[cid] or {}
	return info_table[cid]
end

-- aliases for existing chain-related functions (should eventually become the main names)
Chain.ChangeOperation	 = Duel.ChangeChainOperation
Chain.CanTarget		     = Duel.CheckChainTarget
Chain.HasUniqueCardNames = Duel.CheckChainUniqueness
Chain.GetTriggeringEvent = Duel.GetChainEvent
Chain.GetCurrentLink	 = Duel.GetCurrentChain
Chain.IsDisablable	     = Duel.IsChainDisablable
Chain.IsNegatable		 = Duel.IsChainNegatable
Chain.IsResolving		 = Duel.IsChainSolving
Chain.SetLimit		     = Duel.SetChainLimit
Chain.SetLimitTillEnd	 = Duel.SetChainLimitTillChainEnd

-- split Duel.GetChainEvent into individual functions
local function chain_event_fn(n)
	return function(ch)
		return (select(n,Duel.GetChainEvent(ch or 0)))
	end
end

Chain.GetEventGroup   = chain_event_fn(1)
Chain.GetEventPlayer  = chain_event_fn(2)
Chain.GetEventValue   = chain_event_fn(3)
Chain.GetReasonEffect = chain_event_fn(4)
Chain.GetReason       = chain_event_fn(5)
Chain.GetReasonPlayer = chain_event_fn(6)
