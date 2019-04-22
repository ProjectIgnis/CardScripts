function c210555501.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_SEARCH)
    e1:SetCost(c210555501.cost)
	e1:SetTarget(c210555501.target)
	e1:SetOperation(c210555501.activate)
	c:RegisterEffect(e1)
end
function c210555501.cfilter(c)
	return c:IsCode(89943723)and c:IsAbleToGraveAsCost()
end
function c92353449.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c92353449.cfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c92353449.cfilter,tp,LOCATION_DECK,0,,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function c92353449.thfilter(c)
	return c:IsSetCard(0x1f) and c:IsType(TYPE_MONSTER)and c:IsAbleToHand()
end
function c92353449.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c92353449.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c92353449.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c92353449.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
