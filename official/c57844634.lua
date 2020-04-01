--素早いムササビ
local s,id=GetID()
function s.initial_effect(c)
	--battle destroyed
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UNRELEASABLE_SUM)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
s.listed_names={id}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,tp,LOCATION_DECK)
end
function s.filter(c,e,tp)
	return c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK,1-tp)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	Duel.Damage(1-tp,500,REASON_EFFECT)
	if ft<=0 then return end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		Duel.SpecialSummonStep(g:GetFirst(),0,tp,1-tp,false,false,POS_FACEUP_ATTACK)
		if ft>1 and #g>1 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.SpecialSummonStep(g:GetNext(),0,tp,1-tp,false,false,POS_FACEUP_ATTACK)
		end
		Duel.SpecialSummonComplete()
	end
end
