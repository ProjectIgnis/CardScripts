--竜の交感
--Draconnection
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.thfilter(c,lv)
	return c:IsRace(RACE_DRAGON) and c:IsLevel(lv) and c:IsAbleToHand()
end
function s.revfilter(c,tp)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToDeck() and not c:IsPublic()
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetLevel())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.revfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g1=Duel.SelectMatchingCard(tp,s.revfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	if #g1==0 then return end
	Duel.ConfirmCards(1-tp,g1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g2=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,g1:GetFirst():GetLevel())
	if #g2==0 then return end
	Duel.BreakEffect()
	if Duel.SendtoHand(g2,nil,REASON_EFFECT)>0 and g2:GetFirst():IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g2)
		Duel.BreakEffect()
		Duel.SendtoDeck(g1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end