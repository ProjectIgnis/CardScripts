--サンダー・シーホース
--Thunder Sea Horse (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.filter(c,g)
	return g:IsExists(Card.IsCode,1,c,c:GetCode())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_DECK,0,nil)
		return g:IsExists(s.filter,1,nil,g)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_DECK,0,nil)
	local sg=g:Filter(s.filter,nil,g)
	if #sg==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local hg1=sg:Select(tp,1,1,nil)
	local hg2=sg:Filter(Card.IsCode,hg1:GetFirst(),hg1:GetFirst():GetCode())
	hg1:AddCard(hg2:GetFirst())
	Duel.SendtoHand(hg1,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,hg1)
end
