--Isotomato SCRAMptious Shutdown
--AlphaKretin
function c210310117.initial_effect(c)
	--Negate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(c210310117.condition)
	e1:SetCost(c210310117.cost)
	e1:SetTarget(c210310117.target)
	e1:SetOperation(c210310117.operation)
	c:RegisterEffect(e1)
end
function c210310117.cfilter(c,tp)
	return c:IsOnField() and c:IsType(TYPE_MONSTER) and (c:IsSetCard(0xf32) or c:IsSetCard(0xf33)) and c:IsControler(tp)
end
function c210310117.condition(e,tp,eg,ep,ev,re,r,rp)
	if tp==ep or not Duel.IsChainNegatable(ev) then return false end
	if not re:IsActiveType(TYPE_MONSTER) and not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc+tg:FilterCount(c210310117.cfilter,nil,tp)-tg:GetCount()>0
end
function c210310117.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,aux.FilterBoolFunction(Card.IsSetCard,0xf34),1,nil) end
	local g=Duel.SelectReleaseGroup(tp,aux.FilterBoolFunction(Card.IsSetCard,0xf34),1,1,nil)
	Duel.Release(g,REASON_COST)
end
function c210310117.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function c210310117.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
