--Aquatic Subversion
function c210001100.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCountLimit(1,210001100)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c210001100.target1)
	e1:SetOperation(c210001100.operation1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCountLimit(1,210001101)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(aux.exccon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c210001100.target2)
	e2:SetOperation(c210001100.operation2)
	c:RegisterEffect(e2)
end
function c210001100.thfilter1(c,e,tp)
	return c:IsSetCard(0xfed) and c:IsAbleToHand() and Duel.IsExistingMatchingCard(c210001100.thfilter2,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end
function c210001100.thfilter2(c,e,tp,sc)
	return c:IsSetCard(0xfed) and c:IsAbleToHand() and not c:IsCode(sc:GetCode())
end
function c210001100.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210001100.thfilter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,0,2,0,0)
end
function c210001100.operation1(e,tp,eg,ev,re,r,rp)
	local c=e:GetHandler()
	local thg=Duel.SelectMatchingCard(tp,c210001100.thfilter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	if thg:GetCount()>0 and Duel.SendtoHand(thg,nil,REASON_EFFECT)~=0 then
		thg=Duel.SelectMatchingCard(tp,c210001100.thfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,thg:GetFirst())
		Duel.SendtoHand(thg,nil,REASON_EFFECT)
	end
end
function c210001100.thfilter(c)
	return c:IsSetCard(0xfed) and c:IsAbleToHand()
end
function c210001100.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c210001100.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c210001100.thfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.SelectTarget(tp,c210001100.thfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function c210001100.operation2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
