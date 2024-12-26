--Ｍ∀ＬＩＣＥ＜Ｃ＞ＴＢ－１１
--Maliss <C> TB-11
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 "Maliss" monster from your Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Can be activated the turn it was Set by banishing 1 face-up "Maliss" monster you control
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetValue(function(e) e:SetLabel(1) end)
	e2:SetCondition(function(e)
		local tp=e:GetHandlerPlayer()
		local loc=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>=3 and (LOCATION_DECK|LOCATION_EXTRA) or LOCATION_DECK
		return Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_MZONE,0,1,nil,loc,e,tp)
	end)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
	--Workaround: Unaffected by other EFFECT_TRAP_ACT_IN_SET_TURN effects while the field is full
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetCondition(function(e)
		local tp=e:GetHandlerPlayer()
		local loc=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>=3 and (LOCATION_DECK|LOCATION_EXTRA) or LOCATION_DECK
		return not Duel.IsExistingMatchingCard(s.spfilter,tp,loc,0,1,nil,e,tp)
	end)
	e3:SetValue(function(e,te) return te:GetCode()==EFFECT_TRAP_ACT_IN_SET_TURN and te~=e2 end)
	c:RegisterEffect(e3)
end
s.listed_series={SET_MALISS}
function s.spcostfilter(c,loc,e,tp)
	return c:IsFaceup() and c:IsSetCard(SET_MALISS) and c:IsAbleToRemove(tp)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,loc,0,1,nil,e,tp,c)
end
function s.spfilter(c,e,tp,mc,ignore_zone_chk)
	if not (c:IsMonster() and c:IsSetCard(SET_MALISS) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	if mc or not ignore_zone_chk then
		if c:IsLocation(LOCATION_EXTRA) then
			return c:IsType(TYPE_LINK) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
		else
			return Duel.GetMZoneCount(tp,mc)>0
		end
	end
	return true
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	local label_obj=e:GetLabelObject()
	if chk==0 then label_obj:SetLabel(0) return true end
	if label_obj:GetLabel()>0 then
		label_obj:SetLabel(0)
		local loc=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>=3 and (LOCATION_DECK|LOCATION_EXTRA) or LOCATION_DECK
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_MZONE,0,1,1,nil,loc,e,tp)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ignore_zone_chk=e:GetHandler():IsStatus(STATUS_SET_TURN) and e:GetLabel()==100
		e:SetLabel(0)
		local loc=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>=3 and (LOCATION_DECK|LOCATION_EXTRA) or LOCATION_DECK
		return Duel.IsExistingMatchingCard(s.spfilter,tp,loc,0,1,nil,e,tp,nil,ignore_zone_chk)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>=3 and (LOCATION_DECK|LOCATION_EXTRA) or LOCATION_DECK
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,loc,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		local tc=g:GetFirst()
		--Cannot attack
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3206)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
		--Cannot activate its effects
		local e2=e1:Clone()
		e2:SetDescription(3302)
		e2:SetCode(EFFECT_CANNOT_TRIGGER)
		tc:RegisterEffect(e2)
	end
end