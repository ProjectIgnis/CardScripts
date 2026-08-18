--絶超デモンスダイブ
--Rebel's Dive
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	-- Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsMonster() and c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,2,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return ep==1-tp and tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE) and tc:IsLevelBelow(4) end
	tc:CreateEffectRelation(e)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevelAbove(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	Duel.HintSelection(g)
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)<1 then return end
	--Effect
	local tc=eg:GetFirst()
	local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if tc and Duel.Destroy(tc,REASON_EFFECT)>0 and #sg>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local ssg=sg:Select(tp,1,1,nil)
		if #ssg>0 then
			Duel.SpecialSummon(ssg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
