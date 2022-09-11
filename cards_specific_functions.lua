--filter for the immune effect of qli monsters
function Auxiliary.qlifilter(e,te)
	if te:IsActiveType(TYPE_MONSTER) and te:IsActivated() then
		local lv=e:GetHandler():GetLevel()
		local ec=te:GetOwner()
		if ec:IsType(TYPE_LINK) then
			return false
		elseif ec:IsType(TYPE_XYZ) then
			return ec:GetOriginalRank()<lv
		else
			return ec:GetOriginalLevel()<lv
		end
	else
		return false
	end
end
--filter for necro_valley test
function Auxiliary.nvfilter(c)
	return not c:IsHasEffect(EFFECT_NECRO_VALLEY)
end
function Auxiliary.NecroValleyFilter(f)
	return	function(target,...)
				return f(target,...) and not (target:IsHasEffect(EFFECT_NECRO_VALLEY) and Duel.IsChainDisablable(0))
			end
end

--sp_summon condition for gladiator beast monsters
function Auxiliary.gbspcon(e,tp,eg,ep,ev,re,r,rp)
	local st=e:GetHandler():GetSummonType()
	return st>=(SUMMON_TYPE_SPECIAL+100) and st<(SUMMON_TYPE_SPECIAL+150)
end

--sp_summon condition for evolsaur monsters
function Auxiliary.evospcon(e,tp,eg,ep,ev,re,r,rp)
	local st=e:GetHandler():GetSummonType()
	return st>=(SUMMON_TYPE_SPECIAL+150) and st<(SUMMON_TYPE_SPECIAL+180)
end

--check for Spirit Elimination
function Auxiliary.SpElimFilter(c,mustbefaceup,includemzone)
	--includemzone - contains MZONE in original requirement
	--NOTE: Should only check LOCATION_MZONE+LOCATION_GRAVE
	if c:IsMonster() then
		if mustbefaceup and c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return false end
		if includemzone then return c:IsLocation(LOCATION_MZONE) or not Duel.IsPlayerAffectedByEffect(c:GetControler(),69832741) end
		if Duel.IsPlayerAffectedByEffect(c:GetControler(),69832741) then
			return c:IsLocation(LOCATION_MZONE)
		else
			return c:IsLocation(LOCATION_GRAVE)
		end
	else
		return includemzone or c:IsLocation(LOCATION_GRAVE)
	end
end

--check for Eyes Restrict equip limit
function Auxiliary.AddEREquipLimit(c,con,equipval,equipop,linkedeff,prop,resetflag,resetcount)
	local finalprop=EFFECT_FLAG_CANNOT_DISABLE
	if prop~=nil then
		finalprop=finalprop|prop
	end
	local e1=Effect.CreateEffect(c)
	if con then
		e1:SetCondition(con)
	end
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(finalprop,EFFECT_FLAG2_MAJESTIC_MUST_COPY)
	e1:SetCode(89785779)
	e1:SetLabelObject(linkedeff)
	if resetflag and resetcount then
		e1:SetReset(resetflag,resetcount)
	elseif resetflag then
		e1:SetReset(resetflag)
	end
	e1:SetValue(function(ec,c,tp) return equipval(ec,c,tp) end)
	e1:SetOperation(function(c,e,tp,tc) equipop(c,e,tp,tc) end)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(finalprop&~EFFECT_FLAG_CANNOT_DISABLE,EFFECT_FLAG2_MAJESTIC_MUST_COPY)
	e2:SetCode(89785779+EFFECT_EQUIP_LIMIT)
	if resetflag and resetcount then
		e2:SetReset(resetflag,resetcount)
	elseif resetflag then
		e2:SetReset(resetflag)
	end
	c:RegisterEffect(e2)
	linkedeff:SetLabelObject(e2)
end

--Parameters:
-- c: the card that will receive the effect
-- extracat: optional, eventual extra categories for the effect. Adding CATEGORY_TODECK is not necessary
-- extrainfo: optional, eventual OperationInfo to be set in the target (see Nebula Neos)
-- extraop: optional, eventual operation to be performed if the card is returned to the ED (see Nebula Neos, NOT Magma Neos)
function Auxiliary.EnableNeosReturn(c,extracat,extrainfo,extraop,returneff)
	if not extracat then extracat=0 end
	--return
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK | extracat)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(Auxiliary.NeosReturnCondition1)
	e1:SetTarget(Auxiliary.NeosReturnTarget(c,extrainfo))
	e1:SetOperation(Auxiliary.NeosReturnOperation(c,extraop))
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(0)
	e2:SetCondition(Auxiliary.NeosReturnCondition2)
	c:RegisterEffect(e2)
	if returneff then
		e1:SetLabelObject(returneff)
		e2:SetLabelObject(returneff)
	end
end
function Auxiliary.NeosReturnCondition1(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsHasEffect(42015635)
end
function Auxiliary.NeosReturnCondition2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsHasEffect(42015635)
end
function Auxiliary.NeosReturnTarget(c,extrainfo)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return true end
		Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
		if extrainfo then extrainfo(e,tp,eg,ep,ev,re,r,rp,chk) end
	end
end
function Auxiliary.NeosReturnSubstituteFilter(c)
	return c:IsCode(14088859) and c:IsAbleToRemoveAsCost()
end
function Auxiliary.NeosReturnOperation(c,extraop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
		local sc=Duel.GetFirstMatchingCard(Auxiliary.NecroValleyFilter(Auxiliary.NeosReturnSubstituteFilter),tp,LOCATION_GRAVE,0,nil)
		if sc and Duel.SelectYesNo(tp,aux.Stringid(14088859,0)) then
			Duel.Remove(sc,POS_FACEUP,REASON_COST)
		else
			Duel.SendtoDeck(c,nil,2,REASON_EFFECT)
		end
		if c:IsLocation(LOCATION_EXTRA) then
			if extraop then
				extraop(e,tp,eg,ep,ev,re,r,rp)
			end
		end
	end
end

--Help functions for the Salamangreats' effects
function Card.IsReincarnationSummoned(c)
	local label=0
	for _,lab in ipairs({c:GetFlagEffectLabel(CARD_SALAMANGREAT_SANCTUARY)}) do
		label = label|lab
	end
	return (label&(c:GetSummonPlayer()+1))~=0
end
local ReincarnationChecked=false
function Auxiliary.EnableCheckReincarnation(c)
	if not ReincarnationChecked then
		ReincarnationChecked=true
		local e1=Effect.GlobalEffect()
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_MATERIAL_CHECK)
		e1:SetValue(Auxiliary.ReincarnationCheckValue)
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
		ge1:SetLabelObject(e1)
		ge1:SetTargetRange(0xff,0xff)
		ge1:SetTarget(Auxiliary.ReincarnationCheckTarget)
		Duel.RegisterEffect(ge1,0)
	end
end
function Auxiliary.ReincarnationCheckTarget(e,c)
	return c:IsType(TYPE_FUSION+TYPE_RITUAL+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
end
function Auxiliary.ReincarnationRitualFilter(c,rc,id,tp)
	return c:IsSummonCode(rc,SUMMON_TYPE_RITUAL,tp,id) and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
end
function Auxiliary.ReincarnationCheckValue(e,c)
	local g=c:GetMaterial()
	local id=c:GetCode()
	local tp=c:GetControler()
	local rc=false
	local label=3
	if c:IsLinkMonster() then
		rc=g:IsExists(Card.IsSummonCode,1,nil,c,SUMMON_TYPE_LINK,tp,id)
	elseif c:IsType(TYPE_FUSION) then
		rc=g:IsExists(Card.IsSummonCode,1,nil,c,SUMMON_TYPE_FUSION,tp,id)
	elseif c:IsType(TYPE_RITUAL) then
		label=0
		if g:IsExists(aux.ReincarnationRitualFilter,1,nil,c,id,0) then
			label=1
		end
		if g:IsExists(aux.ReincarnationRitualFilter,1,nil,c,id,1) then
			label=label+2
		end
		rc=label~=0
	elseif c:IsType(TYPE_SYNCHRO) then
		rc=g:IsExists(Card.IsSummonCode,1,nil,c,SUMMON_TYPE_SYNCHRO,tp,id)
	elseif c:IsType(TYPE_XYZ) then
		rc=g:IsExists(Card.IsSummonCode,1,nil,c,SUMMON_TYPE_XYZ,tp,id)
	end
	if rc then
		c:RegisterFlagEffect(CARD_SALAMANGREAT_SANCTUARY,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,1,label)
	end
end

--Filter for unique on field Malefic monsters
function Auxiliary.MaleficUniqueFilter(cc)
	local mt=cc:GetMetatable()
	local t= mt.has_malefic_unique or {}
	t[cc]=true
	mt.has_malefic_unique=t
	return 	function(c)
				return not Duel.IsPlayerAffectedByEffect(c:GetControler(),75223115) and c:IsSetCard(0x23)
			end
end
--Procedure for Malefic monsters' Special Summon (includes handling of Malefic Paradox Gear)
function Auxiliary.AddMaleficSummonProcedure(c,code,loc,excon)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(Auxiliary.MaleficSummonCondition(code,loc,excon))
	e1:SetTarget(Auxiliary.MaleficSummonTarget(code,loc))
	e1:SetOperation(Auxiliary.MaleficSummonOperation(code,loc))
	c:RegisterEffect(e1)
end
function Auxiliary.MaleficSummonFilter(c,cd)
	return ((cd and c:IsCode(cd)) or (not cd and c:IsSetCard(0x23))) and c:IsAbleToRemoveAsCost()
end
function Auxiliary.MaleficSummonSubstitute(c,cd,tp)
	return c:IsHasEffect(48829461,tp) and c:IsAbleToRemoveAsCost()
end
function Auxiliary.MaleficSummonCondition(cd,loc,excon)
	return 	function(e,c)
				if excon and not excon(e,c) then return false end
				if c==nil then return true end
				return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
					and (Duel.IsExistingMatchingCard(Auxiliary.MaleficSummonFilter,c:GetControler(),loc,0,1,nil,cd)
					or Duel.IsExistingMatchingCard(Auxiliary.MaleficSummonSubstitute,c:GetControler(),LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil,cd,c:GetControler()))
			end
end
function Auxiliary.MaleficSummonTarget(cd,loc)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,c)
				local g=Duel.GetMatchingGroup(Auxiliary.MaleficSummonFilter,tp,loc,0,nil,cd)
				g:Merge(Duel.GetMatchingGroup(Auxiliary.MaleficSummonSubstitute,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil,c:GetControler()))
				local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_REMOVE,nil,nil,true)
				if #sg>0 then
					sg:KeepAlive()
					e:SetLabelObject(sg)
					return true
				end
				return false
			end
end
function Auxiliary.MaleficSummonOperation(cd,loc)
	return	function(e,tp,eg,ep,ev,re,r,rp,c)
				local g=e:GetLabelObject()
				if not g then return end
				local tc=g:GetFirst()
				if tc:IsHasEffect(48829461,tp) then tc:IsHasEffect(48829461,tp):UseCountLimit(tp) end
				Duel.Remove(tc,POS_FACEUP,REASON_COST)
				g:DeleteGroup()
			end
end

--Discard cost for Witchcrafter monsters, supports the replacements from the Continuous Spells
local Witchcrafter={}
function Witchcrafter.DiscardSpell(c)
	return c:IsDiscardable() and c:IsSpell()
end
function Witchcrafter.DiscardCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Witchcrafter.DiscardSpell,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Witchcrafter.DiscardSpell,1,1,REASON_COST+REASON_DISCARD)
end
Auxiliary.WitchcrafterDiscardCost=Auxiliary.CostWithReplace(Witchcrafter.DiscardCost,EFFECT_WITCHCRAFTER_REPLACE)

function Witchcrafter.ReleaseCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
Auxiliary.WitchcrafterDiscardAndReleaseCost=Auxiliary.CostWithReplace(Witchcrafter.DiscardCost,EFFECT_WITCHCRAFTER_REPLACE,nil,Witchcrafter.ReleaseCost)

function Witchcrafter.repcon(e)
	return e:GetHandler():IsAbleToGraveAsCost()
end
function Witchcrafter.repval(base,e,tp,eg,ep,ev,re,r,rp,chk,extracon)
	local c=e:GetHandler()
	return c:IsControler(tp) and c:IsMonster() and c:IsSetCard(0x128)
end
function Witchcrafter.repop(id)
	return function(base,e,tp,eg,ep,ev,re,r,rp)
		Duel.Hint(HINT_CARD,0,id)
		Duel.SendtoGrave(base:GetHandler(),REASON_COST)
	end
end
function Auxiliary.CreateWitchcrafterReplace(c,id)
	local e=Effect.CreateEffect(c)
	e:SetType(EFFECT_TYPE_FIELD)
	e:SetCode(EFFECT_WITCHCRAFTER_REPLACE)
	e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e:SetTargetRange(1,0)
	e:SetRange(LOCATION_SZONE)
	e:SetCountLimit(1,id)
	e:SetCondition(Witchcrafter.repcon)
	e:SetValue(Witchcrafter.repval)
	e:SetOperation(Witchcrafter.repop(id))
	return e
end

--Special Summon limit for "Evil HERO" Fusion monsters
function Auxiliary.EvilHeroLimit(e,se,sp,st)
	return se:GetHandler():IsCode(CARD_DARK_FUSION)
		or (Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(),EFFECT_SUPREME_CASTLE) and st&SUMMON_TYPE_FUSION==SUMMON_TYPE_FUSION)
end
--Special Summon limit for "Fossil" Fusion monsters
function Auxiliary.FossilLimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or se:GetHandler():IsCode(CARD_FOSSIL_FUSION)
end

--Kaiju and Lava Golem-like summon procedures
function Auxiliary.AddLavaProcedure(c,required,position,filter,value,description)
	if not required or required < 1 then
		required = 1
	end
	filter = filter or aux.TRUE
	value = value or 0
	local e1=Effect.CreateEffect(c)
	if description then
		e1:SetDescription(description)
	end
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(position,1)
	e1:SetValue(value)
	e1:SetCondition(Auxiliary.LavaCondition(required,filter))
	e1:SetTarget(Auxiliary.LavaTarget(required,filter))
	e1:SetOperation(Auxiliary.LavaOperation(required,filter))
	c:RegisterEffect(e1)
	return e1
end
function Auxiliary.LavaCheck(sg,e,tp,mg)
	return Duel.GetMZoneCount(1-tp,sg,tp)>0
end
function Auxiliary.LavaCondition(required,filter)
	return function(e,c)
		if c==nil then return true end
		local tp=c:GetControler()
		local mg=Duel.GetMatchingGroup(aux.AND(Card.IsReleasable,filter),tp,0,LOCATION_MZONE,nil)
		return aux.SelectUnselectGroup(mg,e,tp,required,required,Auxiliary.LavaCheck,0)
	end
end
function Auxiliary.LavaTarget(required,filter)
	return function(e,tp,eg,ep,ev,re,r,rp,chk,c)
		local mg=Duel.GetMatchingGroup(aux.AND(Card.IsReleasable,filter),tp,0,LOCATION_MZONE,nil)
		local g=aux.SelectUnselectGroup(mg,e,tp,required,required,Auxiliary.LavaCheck,1,tp,HINTMSG_RELEASE,nil,nil,true)
		if #g > 0 then
			g:KeepAlive()
			e:SetLabelObject(g)
			return true
		else
			return false
		end
	end
end
function Auxiliary.LavaOperation(required,filter)
	return function(e,tp,eg,ep,ev,re,r,rp,c)
		local g=e:GetLabelObject()
		Duel.Release(g,REASON_COST)
		g:DeleteGroup()
	end
end
function Auxiliary.AddKaijuProcedure(c)
	c:SetUniqueOnField(1,0,aux.FilterBoolFunction(Card.IsSetCard,0xd3),LOCATION_MZONE)
	local e1 = aux.AddLavaProcedure(c,1,POS_FACEUP_ATTACK)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_HAND)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e2:SetTargetRange(POS_FACEUP_ATTACK,0)
	e2:SetCondition(Auxiliary.KaijuCondition)
	c:RegisterEffect(e2)
	return e1,e2
end
function Auxiliary.KaijuCondition(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(function(c)
											return c:IsFaceup() and c:IsSetCard(0xd3)
										end,tp,0,LOCATION_MZONE,1,nil)
end
function Auxiliary.CheckStealEquip(c,e,tp)
	if c:IsFacedown() or not c:IsControlerCanBeChanged() or not c:IsControler(1-tp) then return false end
	if e:GetHandler():IsLocation(LOCATION_SZONE) then return true end --Already handled in the core
	if not Duel.IsDuelType(DUEL_TRAP_MONSTERS_NOT_USE_ZONE) and c:IsType(TYPE_TRAPMONSTER) then
		return Duel.GetLocationCount(tp,LOCATION_SZONE,tp,LOCATION_REASON_CONTROL)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE,tp,0)>=2
	end
	return true
end
function Auxiliary.CheckSummonGate(tp,count)
	local tot=nil
	for _,eff in ipairs ({Duel.GetPlayerEffect(tp,CARD_SUMMON_GATE)}) do
		local val=eff:GetValue()
		if val then
			if type(val)=="function" then
				val=val(tp)
			end
			tot=tot and math.min(tot,val) or val
		end
	end
	if count then
		return not tot or tot>=count
	end
	return tot
end

--function related to Clock Lizard
function Auxiliary.addLizardCheck(c)
	--lizard check
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(CARD_CLOCK_LIZARD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	return e1
end
--lizard check with a reset
function Auxiliary.createTempLizardCheck(c,filter,reset,tRange,tRange2,resetcount)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(CARD_CLOCK_LIZARD)
	e1:SetTargetRange(tRange or 0xff,tRange2 or 0)
	e1:SetReset(reset or (RESET_PHASE|PHASE_END),resetcount)
	e1:SetTarget(filter or aux.TRUE)
	e1:SetValue(1)
	return e1
end
function Auxiliary.addTempLizardCheck(c,tp,filter,reset,tRange,tRange2,resetcount)
	local e1=aux.createTempLizardCheck(c,filter,reset,tRange,tRange2,resetcount)
	Duel.RegisterEffect(e1,tp)
	return e1
end
--lizard check for cards like Yang Zing Creation
function Auxiliary.createContinuousLizardCheck(c,location,filter,tRange,tRange2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(CARD_CLOCK_LIZARD)
	e1:SetTargetRange(tRange or 0xff,tRange2 or 0)
	e1:SetRange(location)
	e1:SetTarget(filter or aux.TRUE)
	e1:SetValue(1)
	return e1
end
function Auxiliary.addContinuousLizardCheck(c,location,filter,tRange,tRange2)
	local e1=aux.createContinuousLizardCheck(c,location,filter,tRange,tRange2)
	c:RegisterEffect(e1)
	return e1
end

--Discard and/or send to GY cost for Ice Barrier Monsters, support for Mirror Master of the Ice Barrier
function Auxiliary.IceBarrierDiscardFilter(c,tp)
	return c:IsHasEffect(EFFECT_ICEBARRIER_REPLACE,tp) and c:IsAbleToRemoveAsCost()
end
function Auxiliary.IceBarrierDiscardGroup(minc)
	return function(sg,e,tp,mg)
		return sg:FilterCount(Auxiliary.IceBarrierDiscardFilter,nil,tp)<=1 and #sg>=minc
	end
end
function Auxiliary.IceBarrierDiscardCost(f,discard,minc,maxc)
	local fliter=discard and Card.IsDiscardable or Card.IsAbleToGraveAsCost
	if f then fliter=aux.AND(f,fliter) end
	if not minc then minc=1 end
	if not maxc then maxc=1 end
	local rescon=Auxiliary.IceBarrierDiscardGroup(minc)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.IsExistingMatchingCard(fliter,tp,LOCATION_HAND,0,minc,nil) or Duel.IsExistingMatchingCard(Auxiliary.IceBarrierDiscardFilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
		local g=Duel.GetMatchingGroup(fliter,tp,LOCATION_HAND,0,nil)
		g:Merge(Duel.GetMatchingGroup(Auxiliary.IceBarrierDiscardFilter,tp,LOCATION_GRAVE,0,nil,tp))
		local sg=Auxiliary.SelectUnselectGroup(g,e,tp,minc,maxc,rescon,1,tp,Auxiliary.Stringid(CARD_MIRRORMASTER_ICEBARRIER,1))
		local rm=0
		if sg:IsExists(Card.IsHasEffect,1,nil,EFFECT_ICEBARRIER_REPLACE,tp) then
			local te=sg:Filter(Card.IsHasEffect,nil,EFFECT_ICEBARRIER_REPLACE)
			te:GetFirst():GetCardEffect(EFFECT_ICEBARRIER_REPLACE):UseCountLimit(tp)
			rm=Duel.Remove(te,POS_FACEUP,REASON_COST)
			sg:Sub(te)
		end
		if #sg>0 then
			if discard then
				return Duel.SendtoGrave(sg,REASON_COST+REASON_DISCARD) + rm
			else
				return Duel.SendtoGrave(sg,REASON_COST) + rm
			end
		else
			return rm
		end
	end
end

--Shortcut for "Security Force" archetype's "facing"
--(card in the same column as a security force)
function Auxiliary.SecurityTarget(e,_c)
	return _c:GetColumnGroup():IsExists(function(c,tp)
											return c:IsControler(tp) and c:IsFaceup() and c:IsMonster() and c:IsSetCard(0x15a)
										 end,1,_c,e:GetHandlerPlayer())
end

-- Description: Checks for whether the equip card still has the equip effect once it reaches SZONE
-- This is used to correct the interaction between Phantom of Chaos (or alike) and any monsters that equip themselves to another
function Auxiliary.ZWEquipLimit(tc,te)
	return function(e,c)
		if c~=tc then return false end
		local effs={e:GetHandler():GetCardEffect(75402014+EFFECT_EQUIP_LIMIT)}
		for _,eff in ipairs(effs) do
			if eff==te then return true end
		end
		return false
	end
end
-- Description: Operation of equipping a card to another by its own effect and registering equip limit, used with aux.AddZWEquipLimit
-- c - equip card
-- e - usually linkedeffect
-- tp - trigger player
-- tc - equip target
-- code - used if a flag effect needs to be registered
-- previousPos - boolean, determine whether the equip card will use its Position from the previous location, default to true
function Auxiliary.EquipAndLimitRegister(c,e,tp,tc,code,previousPos)
	if not Duel.Equip(tp,c,tc,previousPos==nil and true or previousPos) then return false end
	--Add Equip limit
	if code then
		tc:RegisterFlagEffect(code,RESET_EVENT+RESETS_STANDARD,0,0)
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(Auxiliary.ZWEquipLimit(tc,e:GetLabelObject()))
	c:RegisterEffect(e1)
	return true
end
-- Description: Equip Limit Proc for cards that equip themselves to another card
-- con - condition for when the card can equip to another 'f(e)'
-- equipval - filter for the equip target
-- equipop - what happens when the card is equipped to the target
-- (tc is equip target, c is equip card)
-- linkedeffect - usually the effect of Card c that equips, this ensures Phantom of Chaos handling
-- prop - extra effect properties
-- resetflag/resetcount - resets
function Auxiliary.AddZWEquipLimit(c,con,equipval,equipop,linkedeff,prop,resetflag,resetcount)
	local finalprop=prop and prop|EFFECT_FLAG_CANNOT_DISABLE or EFFECT_FLAG_CANNOT_DISABLE
	local e1=Effect.CreateEffect(c)
	if con then
		e1:SetCondition(con)
	end
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(finalprop,EFFECT_FLAG2_MAJESTIC_MUST_COPY)
	e1:SetCode(75402014)
	e1:SetLabelObject(linkedeff)
	if resetflag and resetcount then
		e1:SetReset(resetflag,resetcount)
	elseif resetflag then
		e1:SetReset(resetflag)
	end
	e1:SetValue(function(tc,c,tp) return equipval(tc,c,tp) end)
	e1:SetOperation(function(c,e,tp,tc) equipop(c,e,tp,tc) end)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(finalprop&~EFFECT_FLAG_CANNOT_DISABLE,EFFECT_FLAG2_MAJESTIC_MUST_COPY)
	e2:SetCode(75402014+EFFECT_EQUIP_LIMIT)
	if resetflag and resetcount then
		e2:SetReset(resetflag,resetcount)
	elseif resetflag then
		e2:SetReset(resetflag)
	end
	c:RegisterEffect(e2)
	linkedeff:SetLabelObject(e2)
end

-- Amazement and Ɐttraction helper functions
AA = {}
function AA.eqtgfilter(c,tp)
	return c:IsFaceup() and (c:IsSetCard(0x15e) or (not c:IsControler(tp)))
end
function AA.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and AA.eqtgfilter(chkc,tp) end
	if chk==0 then
		return e:IsHasType(EFFECT_TYPE_ACTIVATE) and
			   Duel.IsExistingTarget(AA.eqtgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,AA.eqtgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function AA.eqlim(e,c)
	return c:GetControler()==e:GetHandlerPlayer() or e:GetHandler():GetEquipTarget()==c
end
function AA.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if (not c:IsLocation(LOCATION_SZONE)) or (not c:IsRelateToEffect(e)) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Equip(tp,c,tc)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(AA.eqlim)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1)
	else
		c:CancelToGrave(false)
	end
end
-- Description: Add equip effect that "Ɐttraction" traps share to a card, effect text being:
-- Target 1 "Amazement" monster you control or 1 face-up monster your opponent controls; equip this card to it.
-- Parameter:
-- c - The card to add the effect to.
function Auxiliary.AddAttractionEquipProc(c)
	--Equip this card to 1 monster
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(aux.RemainFieldCost)
	e1:SetTarget(AA.eqtg)
	e1:SetOperation(AA.eqop)
	c:RegisterEffect(e1)
end
--Returns if the card is equipped and if the equipped monster is controlled by the player (self=true) or by the opponent (self=false)
function Auxiliary.AttractionEquipCon(self)
	return function(e)
		local et=e:GetHandler():GetEquipTarget()
		return et and (et:GetControler()==e:GetHandlerPlayer())==self
	end
end
function AA.eqsfilter(c,tp)
	return c:IsSetCard(0x15f) and c:IsTrap() and c:GetEquipTarget() and
		   Duel.IsExistingMatchingCard(AA.eqmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c:GetEquipTarget(),tp)
end
function AA.eqmfilter(c,tp)
	return c:IsFaceup() and (c:IsSetCard(0x15e) or (not c:IsControler(tp)))
end
function AA.qeqetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(AA.eqsfilter,tp,LOCATION_SZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,AA.eqsfilter,tp,LOCATION_SZONE,0,1,1,nil,tp)
end
function AA.qeqeop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetTargetCards(e):GetFirst()
	if not tc then return end
	local mg=Duel.GetMatchingGroup(AA.eqmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,tc:GetEquipTarget(),tp)
	if #mg==0 then return end
	local mc=mg:Select(tp,1,1,nil):GetFirst()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and
	   mc:IsFaceup() then Duel.Equip(tp,tc,mc) end
end
-- Description: adds the following effect to a card:
--(Quick Effect): You can target 1 of your "Ɐttraction" Traps that is equipped to a monster; equip it to 1 "Amazement" monster you control or 1 face-up monster your opponent controls.
-- c - The card to add the effect to.
-- id - The id of the card used for the HOPT clause.
function Auxiliary.AddAmazementQuickEquipEffect(c,id)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetTarget(AA.qeqetg)
	e2:SetOperation(AA.qeqeop)
	c:RegisterEffect(e2)
end
-- Description: cost for "Security Force" cards that banish a card from the hand, needed for "Security Force Chase" from LIOV
local SecurityForce={}
function SecurityForce.CostFilter(c)
	return c:IsSetCard(0x15a) and c:IsAbleToRemoveAsCost()
end
function SecurityForce.Cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(SecurityForce.CostFilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rg=Duel.SelectMatchingCard(tp,SecurityForce.CostFilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
Auxiliary.SecurityForceCost=Auxiliary.CostWithReplace(SecurityForce.Cost,CARD_SECURITYFORCE_CHASE)
--Standard functions for the "Ursarctic" Special Summoning Quick Effects
local Ursarctic={}
function Ursarctic.spcfilter(c)
	return c:IsLocation(LOCATION_HAND) and c:IsLevelAbove(7)
end
function Ursarctic.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,Ursarctic.spcfilter,1,true,nil,c) end
	local g=Duel.SelectReleaseGroupCost(tp,Ursarctic.spcfilter,1,1,true,nil,c)
	Duel.Release(g,REASON_COST)
end
function Ursarctic.summontarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function Ursarctic.summonoperation(id)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) then
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
		--Cannot Special Summon, except monsters with a Level
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetTargetRange(1,0)
		e1:SetTarget(function(e,c) return not c:IsLevelAbove(0) end)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function Auxiliary.CreateUrsarcticSpsummon(c,id)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(Duel.IsMainPhase)
	e1:SetCost(Auxiliary.CostWithReplace(Ursarctic.spcost,CARD_URSARCTIC_BIG_DIPPER))
	e1:SetTarget(Ursarctic.summontarget)
	e1:SetOperation(Ursarctic.summonoperation(id))
	return e1
end
local Stardust={}
function Stardust.ReleaseSelfCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
Auxiliary.StardustCost=Auxiliary.CostWithReplace(Stardust.ReleaseSelfCost,84012625)

function Auxiliary.DoubleSnareValidity(c,range,property)
	if c then
		if not property then property=0 end
		local eff=Effect.CreateEffect(c)
		eff:SetType(EFFECT_TYPE_SINGLE)
		eff:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SINGLE_RANGE|property)
		eff:SetRange(range)
		eff:SetCode(3682106)
		c:RegisterEffect(eff)
	end
end
--Standard target and operation functions for the "Cyberdark" effects that Trigger on Normal/Special Summon (also see "Cyberdark World")
Cyberdark={}
function Cyberdark.EquipFilter(f)
	return	function(c,tp)
				return c:CheckUniqueOnField(tp) and not c:IsForbidden() and (not f or f(c))
			end
end
function Cyberdark.EquipTarget(f,targets,mandatory)
	f=Cyberdark.EquipFilter(f)
	if targets then
		return Cyberdark.EquipTarget_TG(f,mandatory)
	else
		return Cyberdark.EquipTarget_NTG(f,mandatory)
	end
end
function Cyberdark.EquipOperation(f,op,targets)
	f=Cyberdark.EquipFilter(f)
	if targets then
		return Cyberdark.EquipOperation_TG(f,op)
	else
		return Cyberdark.EquipOperation_NTG(f,op)
	end
end
function Cyberdark.EquipTarget_TG(f,mandatory)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		local wc=Duel.IsPlayerAffectedByEffect(tp,EFFECT_CYBERDARK_WORLD)
		if chkc then return chkc:IsLocation(LOCATION_GRAVE) and (wc or chkc:IsControler(tp)) and f(chkc,tp) end
		local loc=0
		if wc then loc=LOCATION_GRAVE end
		if chk==0 then return mandatory or (Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingTarget(f,tp,LOCATION_GRAVE,loc,1,nil,tp)) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local g=Duel.SelectTarget(tp,f,tp,LOCATION_GRAVE,loc,1,1,nil,tp)
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
		Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	end
end
function Cyberdark.EquipTarget_NTG(f,mandatory)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
		local wc=Duel.IsPlayerAffectedByEffect(tp,EFFECT_CYBERDARK_WORLD)
		local loc,player=0,tp
		if wc then
			loc=LOCATION_GRAVE
			player=PLAYER_ALL
		end
		if chk==0 then return mandatory or (Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(f,tp,LOCATION_GRAVE,loc,1,nil,tp)) end
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,player,0)
		Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,player,LOCATION_GRAVE)
	end
end
function Cyberdark.EquipOperation_TG(f,op)
	return	function(e,tp,eg,ep,ev,re,r,rp)
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		local c=e:GetHandler()
		if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) and f(tc,tp) then
			op(c,e,tp,tc)
		end
	end
end
function Cyberdark.EquipOperation_NTG(f,op)
	return	function(e,tp,eg,ep,ev,re,r,rp)
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		local c=e:GetHandler()
		if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
		local wc=Duel.IsPlayerAffectedByEffect(tp,EFFECT_CYBERDARK_WORLD)
		local loc=0
		if wc then loc=LOCATION_GRAVE end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(f),tp,LOCATION_GRAVE,loc,1,1,nil,tp)
		local tc=g:GetFirst()
		if tc then
			op(c,e,tp,tc)
		end
	end
end

Drytron={}
function Drytron.TributeCostFilter(c,tp)
	return ((c:IsSetCard(0x151) and c:IsMonster()) or c:IsRitualMonster()) and (c:IsControler(tp) or c:IsFaceup())
		and (c:IsInMainMZone(tp) or Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
end
function Drytron.TributeBaseCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,Drytron.TributeCostFilter,1,true,nil,e:GetHandler(),tp) end
	local sg=Duel.SelectReleaseGroupCost(tp,Drytron.TributeCostFilter,1,1,true,nil,e:GetHandler(),tp)
	Duel.Release(sg,REASON_COST)
end
function Drytron.TributeExtraCost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local id=c:GetOriginalCode()
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	--Cannot Special Summon this turn, except Unsummonable
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(Drytron.TributeSummonLimit)
	Duel.RegisterEffect(e1,tp)
end
function Drytron.TributeSummonLimit(e,c)
	return c:IsSummonableCard()
end
Drytron.TributeCost=aux.CostWithReplace(Drytron.TributeBaseCost,CARD_URSARCTIC_DRYTRON,nil,Drytron.TributeExtraCost)

--[[
	Effect.CreateMysteruneQPEffect(c,id,[uniquecat,uniquetg,uniqueop,rmcount,uniqueprop,uniquecode])

	Creates an activation Effect object for the "Mysterune" Quick-Play Spells.

	Card c: the owner of the Effect
	int id: the card ID used for the HOPT restriction and strings
	int uniquecat: the category of the unique effect
	function uniquetg: the unique effect's target function, excluding the banishment handling
	function uniqueop: the unique effect's operation function, excluding the banishment handling,
		the function must return true to proceed to the banishment part
	int|function rmcount: the amount of cards to be banished from the opponent's deck if op is chosen,
		can be a function with the signature (e,tp,eg,ep,ev,re,r,rp)
	int uniqueprop: additional Effect properties if the unique effect is chosen
	int uniquecode: a separate timing where the unique effect can be activated (instead of FREE_CHAIN)
		if provided, the function will return the two Effect objects separately (unique effect first)
--]]
Effect.CreateMysteruneQPEffect = (function()
	local function skipop(e,tp,eg,ep,ev,re,r,rp)
		if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
		-- Skip next Battle Phase
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SKIP_BP)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		if Duel.IsTurnPlayer(tp) and Duel.IsBattlePhase() then
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetCondition(function(e) return Duel.GetTurnCount()~=e:GetLabel() end)
			e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,1)
		end
		Duel.RegisterEffect(e1,tp)
	end

	local function spfilter(c,e,tp)
		return c:IsSetCard(0x180) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and Duel.GetLocationCountFromEx(tp,tp,nil,c,0x60)>0
	end

	local function sptg(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.IsExistingMatchingCard(spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	end

	local function spop(e,tp,eg,ep,ev,re,r,rp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,0x60)
		end
		skipop(e,tp,eg,ep,ev,re,r,rp)
	end

	local function rmtg(e,tp,eg,ep,ev,re,r,rp,chk,uniquetg,rmcount)
		local ct=type(rmcount)=="number" and rmcount or rmcount(e,tp,eg,ep,ev,re,r,rp)
		if chk==0 then return (not uniquetg or uniquetg(e,tp,eg,ep,ev,re,r,rp,0)) and ct>0
			and Duel.IsPlayerCanRemove(tp) and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>=ct end
		if uniquetg then uniquetg(e,tp,eg,ep,ev,re,r,rp,1) end
		if ct>0 then Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,ct,1-tp,LOCATION_DECK) end
	end

	local function rmop(e,tp,eg,ep,ev,re,r,rp,uniqueop,rmcount)
		if (not uniqueop or uniqueop(e,tp,eg,ep,ev,re,r,rp)) and Duel.IsPlayerCanRemove(tp) then
			local ct=type(rmcount)=="number" and rmcount or rmcount(e,tp,eg,ep,ev,re,r,rp)
			local rg=Duel.GetDecktopGroup(1-tp,ct)
			if #rg>0 then
				Duel.DisableShuffleCheck()
				if uniqueop then Duel.BreakEffect() end -- don't break effect if we're only banishing
				Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
			end
		end
		skipop(e,tp,eg,ep,ev,re,r,rp)
	end

	local function choicetg(id,uniquecat,uniquetg,uniqueop,rmcount,uniqueprop)
		return function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
			if chkc then return uniquetg and uniquetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc) end
			local b1=rmtg(e,tp,eg,ep,ev,re,r,rp,0,uniquetg,rmcount)
			local b2=sptg(e,tp,eg,ep,ev,re,r,rp,0)
			if chk==0 then return b1 or b2 end
			local sel=Duel.SelectEffect(tp,
				{b1,aux.Stringid(id,0)},
				{b2,aux.Stringid(id,1)})
			if sel==1 then
				if uniqueprop then e:SetProperty(uniqueprop) end
				e:SetCategory(uniquecat|CATEGORY_REMOVE)
				rmtg(e,tp,eg,ep,ev,re,r,rp,1,uniquetg,rmcount)
				e:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
					rmop(e,tp,eg,ep,ev,re,r,rp,uniqueop,rmcount)
				end)
			elseif sel==2 then
				e:SetCategory(CATEGORY_SPECIAL_SUMMON)
				e:SetProperty(0)
				sptg(e,tp,eg,ep,ev,re,r,rp,1)
				e:SetOperation(spop)
			else
				e:SetCategory(0)
				e:SetProperty(0)
				e:SetOperation(nil)
			end
		end
	end

	return function(c,id,uniquecat,uniquetg,uniqueop,rmcount,uniqueprop,uniquecode)
		uniquecat=uniquecat or 0
		rmcount=rmcount or 0
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_ACTIVATE)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
		e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
		if uniquecode then
			-- have the unique effect as separate
			local e0=Effect.CreateEffect(c)
			e0:SetDescription(aux.Stringid(id,0))
			e0:SetCategory(uniquecat|CATEGORY_REMOVE)
			e0:SetType(EFFECT_TYPE_ACTIVATE)
			e0:SetCode(uniquecode)
			e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
			if uniqueprop then
				e0:SetProperty(uniqueprop)
			end
			e0:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
				if chkc then return uniquetg and uniquetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc) end
				if chk==0 then return rmtg(e,tp,eg,ep,ev,re,r,rp,0,uniquetg,rmcount) end
				rmtg(e,tp,eg,ep,ev,re,r,rp,1,uniquetg,rmcount)
			end)
			e0:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
				rmop(e,tp,eg,ep,ev,re,r,rp,uniqueop,rmcount)
			end)
			-- complete the Special Summon effect
			e1:SetDescription(aux.Stringid(id,1))
			e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
			e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return sptg(e,tp,eg,ep,ev,re,r,rp,chk) end
				Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
				sptg(e,tp,eg,ep,ev,re,r,rp,chk)
			end)
			e1:SetOperation(spop)
			return e0,e1
		else
			e1:SetTarget(choicetg(id,uniquecat,uniquetg,uniqueop,rmcount,uniqueprop))
			return e1
		end
	end
end)()

--[[
	Effect.CreateVernalizerSPEffect(c,id,desc,uniquecat,uniquetg,uniqueop)

	Creates an ignition Effect object for the "Vernalizer Fairy" effects that
	discard themselves and another card from the hand.
	Includes handling for "Flower Crown of the Vernalizer Fairy" cost replacement.

	Card c: the owner of the Effect
	int id: the card ID used for the HOPT restriction and strings
	int desc: the string ID of the effect description (will also be used for the limitcount code)
	int uniquecat: the category of the unique effect
	function uniquetg: the target function for the effect
	function uniqueop: the unique effect's operation function, excluding the special summoning and lingering restriction,
		the function must return true to proceed to the special summon,
		it can also return an optional passcode (int) which will be excluded from the special summon
--]]
Effect.CreateVernalizerSPEffect=(function()
	local stringbase=9350312 -- use strings from "Hills and Blooms" so they don't need to be stored in every card

	local function verncostfilter(c)
		return (c:IsMonster() or c:IsSetCard(0x183)) and c:IsDiscardable()
	end

	local function verncost(e,tp,eg,ep,ev,re,r,rp,chk)
		local c=e:GetHandler()
		if chk==0 then return c:IsDiscardable() and Duel.IsExistingMatchingCard(verncostfilter,tp,LOCATION_HAND,0,1,c) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
		local g=Duel.SelectMatchingCard(tp,verncostfilter,tp,LOCATION_HAND,0,1,1,c)
		Duel.SendtoGrave(g+c,REASON_COST+REASON_DISCARD)
	end

	function vernspfilter(c,e,tp,code)
		return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not (code and c:IsCode(code))
	end

	local function vernop(uniqueop,e,tp,eg,ep,ev,re,r,rp)
		local proceed,exemptID=uniqueop(e,tp,eg,ep,ev,re,r,rp)
		if proceed and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(vernspfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp,exemptID)
			and Duel.SelectYesNo(tp,aux.Stringid(stringbase,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(vernspfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,exemptID)
			if #sg>0 then
				Duel.BreakEffect()
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
		-- Cannot activate monster effects, except EARTH monsters'
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetDescription(aux.Stringid(stringbase,2))
		e1:SetTargetRange(1,0)
		e1:SetValue(function(e,re) return re:IsActiveType(TYPE_MONSTER) and not re:GetHandler():IsAttribute(ATTRIBUTE_EARTH) end)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end

	return function(c,id,desc,uniquecat,uniquetg,uniqueop)
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,desc))
		e1:SetCategory(uniquecat|CATEGORY_SPECIAL_SUMMON)
		e1:SetType(EFFECT_TYPE_IGNITION)
		e1:SetRange(LOCATION_HAND)
		e1:SetCountLimit(1,{id,desc})
		e1:SetCost(aux.CostWithReplace(verncost,CARD_VERNALIZER_FLOWER_CROWN))
		e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
			if chk==0 then return uniquetg(e,tp,eg,ep,ev,re,r,rp,chk) end
			uniquetg(e,tp,eg,ep,ev,re,r,rp,chk)
			Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
		end)
		e1:SetOperation(function(...) vernop(uniqueop,...) end)
		return e1
	end
end)()

--[[
	Handles the additional destruction effect for
	"Welcome Labrynth" Normal Traps given by "Labrynth Labyrinth"
--]]
function Auxiliary.WelcomeLabrynthTrapDestroyOperation(e,tp)
	local c=e:GetHandler()
	local addeff=Duel.IsPlayerAffectedByEffect(tp,CARD_LABRYNTH_LABYRINTH)
	if not (addeff and addeff:CheckCountLimit(tp)
		and e:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetActiveType()==TYPE_TRAP
		and c:IsSetCard(0x117f) and not c:IsStatus(STATUS_ACT_FROM_HAND)
		and Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
		and Duel.SelectYesNo(tp,aux.Stringid(CARD_LABRYNTH_LABYRINTH,1))) then return end
	addeff:UseCountLimit(tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	if #g>0 then
		Duel.HintSelection(g,true)
		Duel.BreakEffect()
		Duel.Destroy(g,REASON_EFFECT)
	end
end

-- checks if `c` can be used as cost by `tp` for "Rikka" cards that tribute Plant monsters
function Card.IsRikkaReleasable(c,tp)
	return c:IsRace(RACE_PLANT) or (c:IsControler(1-tp) and c:IsHasEffect(CARD_RIKKA_ARRIVAL))
end
