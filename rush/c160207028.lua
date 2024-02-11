--アビスレイヤー・アプサラス
--Abysslayer Apsaras
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Return Sea Serpent monsters from the GY to the Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=10
end
function s.tdfilter(c)
	return c:IsRace(RACE_SEASERPENT) and c:IsAbleToDeck()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_MZONE)
end
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_SEASERPENT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(8)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,3,nil)
	Duel.HintSelection(g,true)
	Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_COST)
	Duel.SortDeckbottom(tp,tp,#g)
	-- Special Summon
	local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local ssg=sg:Select(tp,1,1,nil)
		if #ssg>0 then
			Duel.BreakEffect()
			local dg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
			if Duel.SpecialSummon(ssg,0,tp,tp,false,false,POS_FACEUP_ATTACK)>0
				and Duel.GetMatchingGroupCount(Card.IsMonster,tp,LOCATION_GRAVE,0,nil)==0
				and #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
				--Destroy 1 face-up Level 8 or lower monster on your opponent's field
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				dg=dg:Select(tp,1,1,nil)
				if #dg==0 then return end
				Duel.HintSelection(dg,true)
				dg:AddMaximumCheck()
				Duel.BreakEffect()
				Duel.Destroy(dg,REASON_EFFECT)
			end
		end
	end
end