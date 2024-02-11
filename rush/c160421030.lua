--一時風鎖
--Temporary Storm Blockade
local s,id=GetID()
function s.initial_effect(c)
	--Send the top 4 cards of your Deck to the GY and shuffle 1 card from the opponent's hand into the Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c,tp)
	return c:GetPreviousLocation()==LOCATION_DECK and c:IsPreviousControler(tp)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,4) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,4)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_HAND)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.DiscardDeck(tp,4,REASON_EFFECT)
	if #Duel.GetOperatedGroup()==4 then
		Duel.BreakEffect()
		local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.ShuffleHand(tp)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local tc=g:RandomSelect(tp,1)
			Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end