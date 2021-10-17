--  お掃除マシン・ゴーガイン
-- Cleaning Machine Gorgain

local s,id=GetID()
function s.initial_effect(c)
	--Send the top 2 cards of deck to GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DECKDES)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.costfilter(c)
return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH)  and c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,2)
end
function s.cfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsType(TYPE_MONSTER)
end
function s.thfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsType(TYPE_NORMAL) and c:IsAbleToHand()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	local c=e:GetHandler()
	local tg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.HintSelection(g)
	if #g>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)>0 then
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