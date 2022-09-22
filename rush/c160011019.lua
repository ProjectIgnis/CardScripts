--蒔きつきのアルピリス
--Alpiris the Sower
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Send the top 3 cards of your Deck to the GY and draw 1 card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsFaceup() and not c:IsRace(RACE_PLANT)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_SUMMON_TURN) and
		not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeckOrExtraAsCost,tp,LOCATION_HAND,0,1,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local td=Duel.SelectMatchingCard(tp,Card.IsAbleToDeckOrExtraAsCost,tp,LOCATION_HAND,0,1,1,nil)
	if #td>0 and Duel.SendtoDeck(td,nil,SEQ_DECKBOTTOM,REASON_COST)>0 then
		--Effect
		if Duel.DiscardDeck(tp,3,REASON_EFFECT)>0 and Duel.GetOperatedGroup():IsExists(Card.IsRace,1,nil,RACE_PLANT)
			and Duel.IsPlayerCanDraw(tp,1)
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end