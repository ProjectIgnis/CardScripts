--信用取引
--Margin Trading
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_DECK,0,1,nil,tp)
		and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_DECK,1,nil,1-tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,PLAYER_ALL,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_DECK,0,nil,tp)
	local g2=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,0,LOCATION_DECK,nil,1-tp)
	if #g1==0 or #g2==0 then return end
	--Opponent can discard 1 card to negate this effect
	if Duel.IsChainDisablable(0) then
		local g=Duel.GetMatchingGroup(Card.IsDiscardable,tp,0,LOCATION_HAND,nil,REASON_EFFECT)
		if #g>0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_DISCARD)
			local sg=g:Select(1-tp,1,1,nil)
			Duel.SendtoGrave(sg,REASON_EFFECT|REASON_DISCARD)
			return
		end
	end
	--Each player looks at the opponent's Deck
	Duel.ConfirmCards(tp,g2)
	Duel.ConfirmCards(1-tp,g1)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local hg2=g2:Select(tp,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(id,2))
	local hg1=g1:Select(1-tp,1,1,nil)
	if #hg1==0 or #hg2==0 then return end
	Duel.BreakEffect()
	Duel.SendtoHand(hg1,nil,REASON_EFFECT)
	Duel.ConfirmCards(tp,hg1)
	Duel.SendtoHand(hg2,nil,REASON_EFFECT)
	Duel.ConfirmCards(tp,hg2)
end