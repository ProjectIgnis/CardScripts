--
--Grand Extreme
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.hdfilter(c,e,tp)
	return (c:IsRace(RACE_FISH) or c:IsRace(RACE_SEASERPENT)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.gyfilter(c)
	return c:IsMonster() and c:IsAbleToDeck()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.hdfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.hdfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
	if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		local og=Duel.GetMatchingGroup(s.gyfilter,tp,0,LOCATION_GRAVE,nil)
		if #og>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local sg=og:Select(tp,1,5,nil)
			Duel.HintSelection(sg)
			Duel.SendtoDeck(sg,1-tp,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
