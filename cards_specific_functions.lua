function Auxiliary.IsGeminiState(effect)
	local c=effect:GetHandler()
	return not c:IsDisabled() and c:IsGeminiState()
end
function Auxiliary.IsNotGeminiState(effect)
	local c=effect:GetHandler()
	return c:IsDisabled() or not c:IsGeminiState()
end
function Auxiliary.GeminiNormalCondition(effect)
	local c=effect:GetHandler()
	return c:IsFaceup() and not c:IsGeminiState()
end
function Auxiliary.EnableGeminiAttribute(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_GEMINI_SUMMONABLE)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ADD_TYPE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetCondition(aux.GeminiNormalCondition)
	e2:SetValue(TYPE_NORMAL)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_REMOVE_TYPE)
	e3:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e3)
end
--register effect of return to hand for Spirit monsters
function Auxiliary.EnableSpiritReturn(c,event1,...)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(event1)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(Auxiliary.SpiritReturnReg)
	c:RegisterEffect(e1)
	for i,event in ipairs{...} do
		local e2=e1:Clone()
		e2:SetCode(event)
		c:RegisterEffect(e2)
	end
end
function Auxiliary.SpiritReturnReg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetDescription(1104)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	if e:GetCode() == EVENT_FLIP_SUMMON_SUCCESS or e:GetCode() == EVENT_FLIP then
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	else
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TEMP_REMOVE-RESET_LEAVE+RESET_PHASE+PHASE_END)
	end
	e1:SetCondition(Auxiliary.SpiritReturnCondition)
	e1:SetTarget(Auxiliary.SpiritReturnTarget)
	e1:SetOperation(Auxiliary.SpiritReturnOperation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	c:RegisterEffect(e2)
end
function Auxiliary.SpiritReturnCondition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsHasEffect(EFFECT_SPIRIT_DONOT_RETURN) then return false end
	if e:IsHasType(EFFECT_TYPE_TRIGGER_F) then
		return not c:IsHasEffect(EFFECT_SPIRIT_MAYNOT_RETURN)
	else return c:IsHasEffect(EFFECT_SPIRIT_MAYNOT_RETURN) end
end
function Auxiliary.SpiritReturnTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function Auxiliary.SpiritReturnOperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
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
	if c:IsType(TYPE_MONSTER) then
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
function Auxiliary.EnableNeosReturn(c,extracat,extrainfo,extraop)
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
			local id=c:GetCode()
			Duel.RaiseSingleEvent(c,EVENT_CUSTOM+id,e,0,0,0,0)
			if extraop then
				extraop(e,tp,eg,ep,ev,re,r,rp)
			end
		end
	end
end

--Help functions for the Salamangreats' effects
function Card.IsReincarnationSummoned(c)
	return c:GetFlagEffect(CARD_SALAMANGREAT_SANCTUARY)~=0
end
function Auxiliary.EnableCheckReincarnation(c)
	local m=_G["c"..CARD_SALAMANGREAT_SANCTUARY]
	if not m then
		m=_G["c"..c:GetCode()]
	end
	if m and not m.global_check then
		m.global_check=true
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
	local tp=c:GetSummonPlayer()
	local rc=false
	if c:IsLinkMonster() then
		rc=g:IsExists(Card.IsSummonCode,1,nil,c,SUMMON_TYPE_LINK,tp,id)
	elseif c:IsType(TYPE_FUSION) then
		rc=g:IsExists(Card.IsSummonCode,1,nil,c,SUMMON_TYPE_FUSION,tp,id)
	elseif c:IsType(TYPE_RITUAL) then
		rc=g:IsExists(aux.ReincarnationRitualFilter,1,nil,c,id,tp)
	elseif c:IsType(TYPE_SYNCHRO) then
		rc=g:IsExists(Card.IsSummonCode,1,nil,c,SUMMON_TYPE_SYNCHRO,tp,id)
	elseif c:IsType(TYPE_XYZ) then
		rc=g:IsExists(Card.IsSummonCode,1,nil,c,SUMMON_TYPE_XYZ,tp,id)
	end
	if rc then
		c:RegisterFlagEffect(CARD_SALAMANGREAT_SANCTUARY,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_LEAVE-RESET_TEMP_REMOVE,0,1)
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
function Auxiliary.AddMaleficSummonProcedure(c,code,loc)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(Auxiliary.MaleficSummonCondition(code,loc))
	e1:SetOperation(Auxiliary.MaleficSummonOperation(code,loc))
	c:RegisterEffect(e1)
end
function Auxiliary.MaleficSummonFilter(c,cd)
	return c:IsCode(cd) and c:IsAbleToRemoveAsCost()
end
function Auxiliary.MaleficSummonSubstitute(c,cd,tp)
	return c:IsHasEffect(48829461,tp) and c:IsAbleToRemoveAsCost()
end
function Auxiliary.MaleficSummonCondition(cd,loc)
	return 	function(e,c)
				if c==nil then return true end
				return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
					and (Duel.IsExistingMatchingCard(Auxiliary.MaleficSummonFilter,c:GetControler(),loc,0,1,nil,cd)
					or Duel.IsExistingMatchingCard(Auxiliary.MaleficSummonSubstitute,c:GetControler(),LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil,cd,c:GetControler()))
			end
end
function Auxiliary.MaleficSummonOperation(cd,loc)
	return	function(e,tp,eg,ep,ev,re,r,rp,c)
				local g=Duel.GetMatchingGroup(Auxiliary.MaleficSummonFilter,tp,loc,0,nil,cd)
				g:Merge(Duel.GetMatchingGroup(Auxiliary.MaleficSummonSubstitute,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil,c:GetControler()))
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
				local tc=g:Select(tp,1,1,nil):GetFirst()
				if tc:IsHasEffect(48829461,tp) then tc:IsHasEffect(48829461,tp):UseCountLimit(tp) end
				Duel.Remove(tc,POS_FACEUP,REASON_COST)
			end
end
--Discard cost for Witchcrafter monsters, supports the replacements from the Continuous Spells
function Auxiliary.WitchcrafterDiscardFilter(c,tp)
	return c:IsHasEffect(EFFECT_WITCHCRAFTER_REPLACE,tp) and c:IsAbleToGraveAsCost()
end
function Auxiliary.WitchcrafterDiscardGroup(minc)
	return	function(sg,e,tp,mg)
				if sg:IsExists(Card.IsHasEffect,1,nil,EFFECT_WITCHCRAFTER_REPLACE,tp) then
					return #sg==1,#sg>1
				else
					return #sg>=minc
				end
			end
end
function Auxiliary.WitchcrafterDiscardCost(f,minc,maxc)
	if f then f=aux.AND(f,Card.IsDiscardable) else f=Card.IsDiscardable end
	if not minc then minc=1 end
	if not maxc then maxc=1 end
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return Duel.IsExistingMatchingCard(f,tp,LOCATION_HAND,0,minc,nil) or Duel.IsExistingMatchingCard(Auxiliary.WitchcrafterDiscardFilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
				local g=Duel.GetMatchingGroup(f,tp,LOCATION_HAND,0,nil)
				g:Merge(Duel.GetMatchingGroup(Auxiliary.WitchcrafterDiscardFilter,tp,LOCATION_ONFIELD,0,nil,tp))
				local sg=Auxiliary.SelectUnselectGroup(g,e,tp,1,maxc,Auxiliary.WitchcrafterDiscardGroup(minc),1,tp,aux.Stringid(EFFECT_WITCHCRAFTER_REPLACE,2))
				if sg:IsExists(Card.IsHasEffect,1,nil,EFFECT_WITCHCRAFTER_REPLACE,tp) then
					local te=sg:GetFirst():IsHasEffect(EFFECT_WITCHCRAFTER_REPLACE,tp)
					te:UseCountLimit(tp)
					Duel.SendtoGrave(sg,REASON_COST)
				else
					Duel.SendtoGrave(sg,REASON_COST+REASON_DISCARD)
				end
			end
end
--Special Summon limit for the Evil HEROes
function Auxiliary.EvilHeroLimit(e,se,sp,st)
	local chk=SUMMON_TYPE_FUSION+0x10
	if Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(),EFFECT_SUPREME_CASTLE) then
		chk=SUMMON_TYPE_FUSION
	end
	return st&chk==chk
end
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