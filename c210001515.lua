--Solar Fruit - Solar Leaf
function c210001515.initial_effect(c)
	--add lita to hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,210001515)
	e1:SetTarget(c210001515.tg)
	e1:SetOperation(c210001515.op)
	c:RegisterEffect(e1)
	--add to hand 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(aux.exccon)
	e2:SetCost(c210001515.cost)
	e2:SetTarget(c210001515.thtarget)
	e2:SetOperation(c210001515.thoperation)
	c:RegisterEffect(e2)
end
function c210001515.f1(c)
	return c:IsFaceup() and c:IsSetCard(0x1f69)
end
function c210001515.f2(c)
	return c:IsCode(210001501) and c:IsAbleToHand()
end
function c210001515.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(c210001515.f1,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(c210001515.f2,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(210001515,0))
	local g=Duel.SelectTarget(tp,c210001515.f1,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND+CATEGORY_SEARCH,nil,1,tp,LOCATION_DECK)
end
function c210001515.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c210001515.f2,tp,LOCATION_DECK,0,1,1,nil)
	if g and #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
function c210001515.sff(c,m)
	return c:IsSetCard(0xf71) and ((m==1 and c:IsAbleToHand()) or (m==0 and c:IsAbleToRemoveAsCost()))
end
function c210001515.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,69832741)
		and c:IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(c210001515.sff,tp,LOCATION_GRAVE,0,1,c,0) end
	local g=Duel.SelectMatchingCard(tp,c210001515.sff,tp,LOCATION_GRAVE,0,1,1,c,0)
	g=g+c
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c210001515.thtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210001515.sff,tp,LOCATION_DECK,0,1,nil,1) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c210001515.thoperation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c210001515.sff,tp,LOCATION_DECK,0,1,1,nil,1)
	if g and #g>0 then
		Duel.SendtoHand(g,tp,REASON_EFFECT)
	end
end