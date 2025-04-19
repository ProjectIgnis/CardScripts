--サイコな埋葬
--Psychic Burial

local s,id=GetID()
function s.initial_effect(c)
	--Send the top 2 cards of your Deck to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,2)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.PayLPCost(tp,1000)
	--Effect
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.DiscardDeck(p,2,REASON_EFFECT)
	local g=Duel.GetMatchingGroup(aux.NOT(Card.IsMaximumModeSide),tp,0,LOCATION_MZONE,nil)
	if Duel.IsPlayerCanDiscardDeck(tp,1) and #g==3 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.DiscardDeck(p,1,REASON_EFFECT)
	end
end