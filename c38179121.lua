--究極進化薬
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.costfilter1(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_DINOSAUR) and c:IsAbleToRemoveAsCost() 
		and (c:IsLocation(LOCATION_HAND) or aux.SpElimFilter(c,true))
end
function s.costfilter2(c)
	return c:IsType(TYPE_MONSTER) and not c:IsRace(RACE_DINOSAUR) and c:IsAbleToRemoveAsCost() 
		and (c:IsLocation(LOCATION_HAND) or aux.SpElimFilter(c,true))
end
function s.filter(c,e,tp)
	return c:IsRace(RACE_DINOSAUR) and c:IsLevelAbove(7) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,e,tp)
	local tc=nil
	if #g==1 and g:GetFirst():IsLocation(LOCATION_HAND) then tc=g:GetFirst() end
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter1,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,1,tc)
		and Duel.IsExistingMatchingCard(s.costfilter2,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,1,tc) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g1=Duel.SelectMatchingCard(tp,s.costfilter1,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,1,1,tc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g2=Duel.SelectMatchingCard(tp,s.costfilter2,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,1,1,tc)
	g1:Merge(g2)
	Duel.Remove(g1,POS_FACEUP,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
