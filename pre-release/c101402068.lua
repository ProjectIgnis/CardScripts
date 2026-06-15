--宇宙的ハリケーン
--Spatial Trunade
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Return up to 2 cards on the field to the hand, then each player places cards from their hand on the bottom of the Deck in any order equal to the number returned to their hand. You can only activate 1 "Spatial Trunade" per turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,PLAYER_EITHER,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,PLAYER_EITHER,LOCATION_HAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local exc=c:IsRelateToEffect(e) and c or nil
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,exc)
	if #g==0 then return end
	Duel.HintSelection(g)
	if Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and #g:Match(Card.IsLocation,nil,LOCATION_HAND)>0 then
		local ct=g:FilterCount(Card.IsControler,nil,tp)
		if ct>0 then Duel.ShuffleHand(tp) end
		if #g>ct then Duel.ShuffleHand(1-tp) end
		Duel.BreakEffect()
		s.place_on_deck_bottom(tp,ct)
		s.place_on_deck_bottom(1-tp,#g-ct)
	end
end
function s.place_on_deck_bottom(p,ct)
	if ct==0 then return end
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,p,LOCATION_HAND,0,nil)
	if #g<ct then return end
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)
	local sg=g:Select(p,ct,ct,nil)
	if #sg==0 then return end
	local sort_ct=Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	if sort_ct>1 then
		Duel.SortDeckbottom(p,p,sort_ct)
	end
end