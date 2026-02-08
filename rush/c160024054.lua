--浅すぎた墓穴
--Lovely Connect
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Send the top 2 cards of your Deck to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={81756897}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,2)
end
function s.thfilter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAttack(0) and c:IsAbleToHand()
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT) 
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	if Duel.DiscardDeck(tp,2,REASON_EFFECT)<1 then return end
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		local g2=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		if #g2>0 then
			Duel.SendtoHand(g2,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g2)
		end
		local g3=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_ONFIELD,nil)
		if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) and #g3>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local sg=g3:Select(tp,1,1,nil)
			Duel.HintSelection(sg)
			if #sg>0 then
				Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
			end
		end
	end
end