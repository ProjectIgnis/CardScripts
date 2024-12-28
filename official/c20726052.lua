--Ｍ∀ＬＩＣＥ＜Ｃ＞ＧＷＣ－０６
--Maliss <C> GWC-06
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 "Maliss" monster from your GY or banishment
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
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
	e2:SetCondition(function(e) return Duel.IsExistingMatchingCard(s.spcostfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil,e:GetHandlerPlayer()) end)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
	--Workaround: Unaffected by other EFFECT_TRAP_ACT_IN_SET_TURN effects while the field is full
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetCondition(function(e) return Duel.GetLocationCount(e:GetHandlerPlayer(),LOCATION_MZONE)==0 end)
	e3:SetValue(function(e,te) return te:GetCode()==EFFECT_TRAP_ACT_IN_SET_TURN and te~=e2 end)
	c:RegisterEffect(e3)
end
s.listed_series={SET_MALISS}
function s.spcostfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(SET_MALISS) and c:IsAbleToRemove(tp) and Duel.GetMZoneCount(tp,c)>0
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	local label_obj=e:GetLabelObject()
	if chk==0 then label_obj:SetLabel(0) return true end
	if label_obj:GetLabel()>0 then
		label_obj:SetLabel(0)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(SET_MALISS) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local zone_chk=true
		if not e:GetHandler():IsStatus(STATUS_SET_TURN) or e:GetLabel()~=100 then
			zone_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		end
		e:SetLabel(0)
		return zone_chk and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
	Duel.SetPossibleOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,0)
end
function s.linkfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_MALISS) and c:IsType(TYPE_LINK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g==0 or Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	local atk=g:GetFirst():GetBaseAttack()
	if atk>0 and Duel.IsExistingMatchingCard(s.linkfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.BreakEffect()
		Duel.Recover(tp,atk,REASON_EFFECT)
	end
end