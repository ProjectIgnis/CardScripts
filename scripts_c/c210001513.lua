--Solar Fruit - Solar Nut
function c210001513.initial_effect(c)
	--add to hand 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,210001513)
	e1:SetCost(c210001513.thcost)
	e1:SetTarget(c210001513.thtarget)
	e1:SetOperation(c210001513.thoperation)
	c:RegisterEffect(e1)
	--add to hand 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(aux.exccon)
	e2:SetCost(c210001513.cost)
	e2:SetTarget(c210001513.target)
	e2:SetOperation(c210001513.operation)
	c:RegisterEffect(e2)
end
function c210001513.cfilter(c,tp)
	return c:IsSetCard(0xf70) and Duel.IsExistingMatchingCard(c210001513.filter,tp,LOCATION_DECK,0,1,c,c:GetCode())
end
function c210001513.filter(c,code)
	return c:IsSetCard(0xf70) and aux.IsCodeListed(c,code) and c:IsAbleToHand()
end
function c210001513.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return Duel.IsExistingMatchingCard(c210001513.cfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	local g=Duel.SelectMatchingCard(tp,c210001513.cfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(g:GetFirst():GetCode())
end
function c210001513.thtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local res=e:GetLabel()~=0
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND+CATEGORY_SEARCH,nil,1,tp,LOCATION_DECK)
end
function c210001513.thoperation(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c210001513.filter,tp,LOCATION_DECK,0,1,1,nil,code)
	if g and #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
function c210001513.sff(c,m)
	return c:IsSetCard(0xf71) and ((m==1 and c:IsAbleToHand()) or (m==0 and c:IsAbleToRemoveAsCost()))
end
function c210001513.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,69832741)
		and c:IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(c210001513.sff,tp,LOCATION_GRAVE,0,1,c,0) end
	local g=Duel.SelectMatchingCard(tp,c210001513.sff,tp,LOCATION_GRAVE,0,1,1,c,0)
	g=g+c
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c210001513.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210001513.sff,tp,LOCATION_DECK,0,1,nil,1) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c210001513.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c210001513.sff,tp,LOCATION_DECK,0,1,1,nil,1)
	if g and #g>0 then
		Duel.SendtoHand(g,tp,REASON_EFFECT)
	end
end