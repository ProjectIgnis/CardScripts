--幻壊兵ニッカ
--Demolition Soldier Nikka
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	-- Mill and add to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.rvlfilter(c,e,tp)
	return c:IsRace(RACE_WYRM) and not c:IsPublic()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rvlfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
function s.cfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsRace(RACE_WYRM) and c:IsAttribute(ATTRIBUTE_FIRE)
end
function s.thfilter(c)
	return c:IsCode(160021015) and c:IsAbleToHand()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local tc=Duel.SelectMatchingCard(tp,s.rvlfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	Duel.ConfirmCards(1-tp,tc)
	Duel.ShuffleHand(tp)
	--Effect
	Duel.DiscardDeck(tp,3,REASON_EFFECT)
	if Duel.GetOperatedGroup():FilterCount(s.cfilter,nil)>0
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end

