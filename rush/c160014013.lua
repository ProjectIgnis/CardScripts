--火燃精ホット
--Hot the Combustible Fairy
local s,id=GetID()
function s.initial_effect(c)
	--Send the top 3 cards of your Deck to the GY and draw 1 card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e)return e:GetHandler():IsStatus(STATUS_SUMMON_TURN)end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local ct=g:GetClassCount(Card.GetRace)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,ct) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,ct)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.filter(c)
	return c:IsRace(RACE_PYRO) and c:IsLocation(LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local ct=g:GetClassCount(Card.GetRace)
	Duel.DiscardDeck(tp,ct,REASON_EFFECT)
	local og=Duel.GetOperatedGroup()
	local ct=og:FilterCount(s.filter,nil)
	if ct>=2 then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end