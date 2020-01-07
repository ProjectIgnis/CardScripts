--Virus Cannon (Anime)
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToGrave()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_DECK+LOCATION_HAND,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,10,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_DECK+LOCATION_HAND,nil):Select(1-tp,10,10,nil)
	Duel.SendtoGrave(g,REASON_EFFECT)
	if #g<10 then
		local cg=Duel.GetFieldGroup(1-tp,LOCATION_DECK+LOCATION_HAND,0)
		Duel.ConfirmCards(tp,cg)
		Duel.ShuffleHand(1-tp)
		Duel.ShuffleDeck(1-tp)
	end
end
