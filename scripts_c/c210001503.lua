--Solar Gun - Gun Del Sol
function c210001503.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,210001503)
	e1:SetTarget(c210001503.target)
	e1:SetOperation(c210001503.operation)
	c:RegisterEffect(e1)
end
c210001503.listed_names={210001503}
function c210001503.tf(c)
	return c:IsFaceup() and c:IsSetCard(0x1f69)
end
function c210001503.sf(c)
	return c:IsSetCard(0xf70) and not c:IsCode(210001503)
end
function c210001503.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return c210001503.tf(chkc) and chkc:IsControler(tp)
		and chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return Duel.IsExistingTarget(c210001503.tf,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(c210001503.sf,tp,LOCATION_DECK,0,1,nil) end
	local tc=Duel.SelectTarget(tp,c210001503.tf,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c210001503.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c210001503.sf,tp,LOCATION_DECK,0,1,1,nil)
	if g and #g>0 then
		Duel.SendtoHand(g,tp,REASON_EFFECT)
	end
end