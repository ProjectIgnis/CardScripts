--コモン・サクリファイス
--Common Sacrifice
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp) and Duel.IsMainPhase() and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>=3
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.GetFieldGroup(tp,0,LOCATION_MZONE):GetMinGroup(Card.GetAttack)
	local g2
	if #g1==1 then g2=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,g1:GetFirst()):GetMinGroup(Card.GetAttack) end
	if chk==0 then return g1 and ((#g1>1 and g1:IsExists(Card.IsAbleToGraveAsCost,2,nil))
		or (#g1==1 and g2 and g1:GetFirst():IsAbleToGraveAsCost() and g2:GetFirst():IsAbleToGraveAsCost())) end
	local g=g1
	if #g1>2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		g=g1:Select(tp,2,2,nil)
	elseif #g1==1 then
		g:Merge(g2)
	end
	Duel.SendtoGrave(g,REASON_COST)
end
function s.filter(c,e,tp)
	return c:IsLevelAbove(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end