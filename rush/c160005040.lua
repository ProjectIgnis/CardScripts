-- JAM:P Start!
--JAM:P Start!
local s,id=GetID()
function s.initial_effect(c)
--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.tdfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_PSYCHIC) and c:IsAbleToDeckAsCost()
end
function s.thfilter(c,tp)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_PSYCHIC) and c:IsAbleToHand()
	and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,2,c,tp)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_PSYCHIC) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	local td=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,2,2,nil,tp)
	Duel.HintSelection(td)
	if Duel.SendtoDeck(td,nil,SEQ_DECKBOTTOM,REASON_COST)~0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
			if g:GetFirst():IsCode(CARD_CAN_D) then
				Duel.BreakEffect()
				Duel.Recover(tp,1000,REASON_EFFECT)
			end
		end
	end
end