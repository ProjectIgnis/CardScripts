--ロマンス・ピック
--Romance Pick
local s,id=GetID()
function s.initial_effect(c)
	--Mill
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DECKDES)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLP(tp)<Duel.GetLP(1-tp)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,500) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
function s.cfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsRace(RACE_PSYCHIC) and c:IsType(TYPE_MONSTER)
end
function s.thfilter(c)
	return c:IsRace(RACE_PSYCHIC) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.PayLPCost(tp,500)
	--Effect
	Duel.DiscardDeck(tp,3,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	local ct=g:FilterCount(s.cfilter,nil)
	if ct>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
