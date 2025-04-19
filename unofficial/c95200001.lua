--Command Duel 1
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,PLAYER_ALL,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_DECK,0,nil)
	local g2=Duel.GetMatchingGroup(Card.IsAbleToHand,1-tp,LOCATION_DECK,0,nil)
	if #g1>0 and #g2>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg1=g1:Select(tp,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)
		local sg2=g2:Select(1-tp,1,1,nil)
		Duel.ConfirmCards(1-tp,sg1)
		Duel.ConfirmCards(tp,sg2)
		sg1:Merge(sg2)
		Duel.SendtoHand(sg1,nil,REASON_EFFECT)
	end
end