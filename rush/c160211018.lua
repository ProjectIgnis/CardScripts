--スペース・コール
--Space Call
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Send the top 3 cards of your Deck to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={160211009}
function s.filter(c)
	return c:IsMonster() and c:IsRace(RACE_CYBERSE) and not c:IsPublic()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
function s.cfilter(c,e,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsMonster() and c:IsRace(RACE_CYBERSE) and c:IsLevelAbove(7)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
	--Effect
	Duel.DiscardDeck(tp,3,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	if g:FilterCount(aux.NecroValleyFilter(s.cfilter),nil,e,tp)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:FilterSelect(tp,aux.NecroValleyFilter(s.cfilter),1,1,nil,e,tp)
		if #sg>0 then
			Duel.BreakEffect()
			if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 and sg:GetFirst():IsCode(160211009) and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
				Duel.Draw(tp,1,REASON_EFFECT)
			end
		end
	end
end