--Impact Survivor - Dragonfly
function c210401009.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsRace,RACE_INSECT),aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_WIND))
	--return to Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2772236,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c210401009.target)
	e1:SetOperation(c210401009.operation)
	c:RegisterEffect(e1)
	--retun to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51858306,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,210401009)
	e2:SetTarget(c210401009.thtg)
	e2:SetOperation(c210401009.thop)
	c:RegisterEffect(e2)
end
function c210401009.tdfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf18) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function c210401009.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c210401009.tdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c210401009.tdfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=Duel.SelectTarget(tp,c210401009.tdfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,sg:GetCount(),0,0)
end
function c210401009.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoDeck(tc,nil,0,REASON_EFFECT)
	end
end
function c210401009.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3d) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c210401009.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c210401009.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c210401009.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c210401009.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c210401009.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end




