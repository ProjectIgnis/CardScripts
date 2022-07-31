--伯蜴参上
--Third Coming of the Reptilian Count
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Shuffle 3 Reptile Normal monster into the deck to Special Summon 1 Reptile from the hand
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.tdfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsType(TYPE_NORMAL) and c:IsLevelBelow(3) and c:IsAbleToDeckOrExtraAsCost()
end
function s.spfilter(c,e,tp,exec)
	return c:IsRace(RACE_REPTILE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (exec or Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,3,c))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	--Requirement
	local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	Duel.HintSelection(g)
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)==0 then return end
	--Effect
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,true)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end	
end
