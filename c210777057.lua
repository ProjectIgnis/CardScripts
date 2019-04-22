--Paleozoic Banffia
--designed and scripted by Naim
function c210777057.initial_effect(c)
    --xyz summon
    aux.AddXyzProcedure(c,c210777057.mfilter,3,3,c210777057.ovfilter,aux.Stringid(210777057,0),3,c210777057.xyzop)
    c:EnableReviveLimit()
	--immune
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c210777057.efilter)
	c:RegisterEffect(e1)
	--negate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(210777057,0))
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c210777057.condition)
	e2:SetCost(c210777057.cost)
	e2:SetTarget(c210777057.target)
	e2:SetOperation(c210777057.operation)
	c:RegisterEffect(e2,false,1)
	--to hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(210777057,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c210777057.thcond)
	e3:SetTarget(c210777057.thtg)
	e3:SetOperation(c210777057.thop)
	c:RegisterEffect(e3,false,1)
end
function c210777057.mfilter(c,xyz,sumtype,tp)
    return c:IsAttribute(ATTRIBUTE_WATER,xyz,sumtype,tp)
end
function c210777057.ovfilter(c,tp,lc)
    return c:IsFaceup() and c:IsType(TYPE_XYZ,lc,SUMMON_TYPE_XYZ,tp) and c:IsRankBelow(2)
end
function c210777057.xyzop(e,tp,chk)
    if chk==0 then return Duel.GetFlagEffect(tp,210777057)==0 end
    Duel.RegisterFlagEffect(tp,210777057,RESET_PHASE+PHASE_END,0,1)
    return true
end
function c210777057.efilter(e,re)
	return re:IsActiveType(TYPE_MONSTER) and re:GetOwner()~=e:GetOwner()
end
function c210777057.overlayfilter(c)
	return c:IsType(TYPE_TRAP) or (c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_WATER))
end
function c210777057.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(c210777057.overlayfilter,1,nil)
end
function c210777057.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function c210777057.filter(c)
	return c:IsFaceup()
end
function c210777057.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and c210777057.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c210777057.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c210777057.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
end
function c210777057.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e2)
	end
end
function c210777057.thcond(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
	and re:GetHandler():IsType(TYPE_TRAP)
	and e:GetHandler():GetOverlayGroup():IsExists(c210777057.overlayfilter,1,nil)
end
function c210777057.thfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
function c210777057.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c210777057.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c210777057.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c210777057.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c210777057.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end