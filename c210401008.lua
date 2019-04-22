--Survivor - Vulture
function c210401008.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85374678,1))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,210401008)
	e1:SetCondition(c210401008.condition)
	e1:SetCost(c210401008.cost)
	e1:SetTarget(c210401008.target)
	e1:SetOperation(c210401008.operation)
	c:RegisterEffect(e1)	
end
function c210401008.hsfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf18) and c:IsLevelAbove(6)
end
function c210401008.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c210401008.hsfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c210401008.drcfilter(c)
	return c:IsSetCard(0xf18) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
function c210401008.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210401008.drcfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,c210401008.drcfilter,1,1,REASON_DISCARD+REASON_COST)
end
function c210401008.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c210401008.operation(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
