--Ｓｐ−ゼロ・リバース
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
	if chk==0 then return tc and tc:IsCanRemoveCounter(tp,0x91,2,REASON_COST) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	tc:RemoveCounter(tp,0x91,2,REASON_COST)
end
function s.filter(c,id,e,tp)
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_EFFECT) and c:GetTurnID()==id and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,Duel.GetTurnCount(),e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft1==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,Duel.GetTurnCount(),e,tp)
	local tc=g:GetFirst()
	local td=tp
	if not tc:IsPreviousControler(tp) then td=1-tp end
	if Duel.SpecialSummonStep(tc,0,tp,td,false,false,POS_FACEUP_ATTACK) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		end
	Duel.SpecialSummonComplete()
end
