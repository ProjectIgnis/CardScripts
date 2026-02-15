--苦渋の選択
--Painful Choice
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.AND(Card.IsAbleToHand,Card.IsAbleToGrave),tp,LOCATION_DECK,0,5,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,4,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<5 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,aux.AND(Card.IsAbleToHand,Card.IsAbleToGrave),tp,LOCATION_DECK,0,5,5,nil)
	if #g~=5 then return end
	local opp=1-tp
	Duel.ConfirmCards(opp,g)
	Duel.Hint(HINT_SELECTMSG,opp,aux.Stringid(id,1))
	local sg=g:Select(opp,1,1,nil)
	if Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 then
		Duel.SendtoGrave(g-sg,REASON_EFFECT)
	end
end