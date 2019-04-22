--Solar Fruit - Speed Nut
function c210001514.initial_effect(c)
	--move
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,210001514)
	e1:SetTarget(c210001514.target)
	e1:SetOperation(c210001514.operation)
	c:RegisterEffect(e1)
	--add to hand 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(aux.exccon)
	e2:SetCost(c210001514.cost)
	e2:SetTarget(c210001514.thtarget)
	e2:SetOperation(c210001514.thoperation)
	c:RegisterEffect(e2)
end
function c210001514.filter(c)
	return c:IsSetCard(0x1f69) and c:CheckAdjacent()
end
function c210001514.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c210001514.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c210001514.filter,tp,LOCATION_MZONE,0,1,nil) end
	local g=Duel.SelectTarget(tp,c210001514.filter,tp,LOCATION_MZONE,0,1,1,nil)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(c210001514.efilter)
	e1:SetReset(RESET_CHAIN)
	g:GetFirst():RegisterEffect(e1)
end
function c210001514.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
function c210001514.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		tc:MoveAdjacent()
	end
end
function c210001514.sff(c,m)
	return c:IsSetCard(0xf71) and ((m==1 and c:IsAbleToHand()) or (m==0 and c:IsAbleToRemoveAsCost()))
end
function c210001514.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,69832741)
		and c:IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(c210001514.sff,tp,LOCATION_GRAVE,0,1,c,0) end
	local g=Duel.SelectMatchingCard(tp,c210001514.sff,tp,LOCATION_GRAVE,0,1,1,c,0)
	g=g+c
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c210001514.thtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210001514.sff,tp,LOCATION_DECK,0,1,nil,1) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c210001514.thoperation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c210001514.sff,tp,LOCATION_DECK,0,1,1,nil,1)
	if g and #g>0 then
		Duel.SendtoHand(g,tp,REASON_EFFECT)
	end
end