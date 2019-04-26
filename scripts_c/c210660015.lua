--Pure-Bloods Graveyard
--concept by Gideon
--scripted by Larry126
function c210660015.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,210660015+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c210660015.condition)
	e1:SetTarget(c210660015.target)
	e1:SetOperation(c210660015.activate)
	c:RegisterEffect(e1)
	--salvage
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c210660015.thcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c210660015.thtg)
	e2:SetOperation(c210660015.thop)
	c:RegisterEffect(e2)
end
function c210660015.filter(c)
	return c:IsCode(86780027) and c:IsAbleToHand()
end
function c210660015.filter1(c,tp)
	return c:IsType(TYPE_MONSTER) and Duel.IsExistingMatchingCard(c210660015.filter2,tp,LOCATION_GRAVE,0,2,c,c:GetRace())
end
function c210660015.filter2(c,race)
	return c:IsType(TYPE_MONSTER) and c:IsRace(race)
end
function c210660015.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c210660015.filter1,tp,LOCATION_GRAVE,0,1,nil,tp)
end
function c210660015.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210660015.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function c210660015.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c210660015.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c210660015.thcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	local ct=g:GetClassCount(Card.GetOriginalRace)
	return (Duel.GetTurnCount()~=e:GetHandler():GetTurnID() or e:GetHandler():IsReason(REASON_RETURN))
		and ct==1 and g:GetCount()>=3
end
function c210660015.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c210660015.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210660015.thfilter,tp,LOCATION_GRAVE,0,2,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_GRAVE)
end
function c210660015.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c210660015.thfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end