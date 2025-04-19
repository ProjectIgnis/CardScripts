-- ドウェルチェア・コリキエル
--Scarechair Relaxer

local s,id=GetID()
function s.initial_effect(c)
	--Send the top 2 cards of deck to GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DECKDES+CATEGORY_RECOVER)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.costfilter(c)
	return c:IsMonster() and c:GetAttack()==0 and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,2)
end
function s.cfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevelBelow(8) and c:IsMonster()
end
function s.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevelBelow(8) and c:IsMonster() and c:IsAbleToHand()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	local c=e:GetHandler()
	local tg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	if Duel.SendtoGrave(tg,REASON_COST)==1 then
		--Effect
		Duel.DiscardDeck(tp,2,REASON_EFFECT)
		local g=Duel.GetOperatedGroup()
		local ct=g:FilterCount(s.cfilter,nil)
		if ct>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
			Duel.HintSelection(g)
			if #g>0 then
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
				local rec=g:GetFirst():GetAttack()
				Duel.Recover(1-tp,rec,REASON_EFFECT)
			end
		end
	end
end