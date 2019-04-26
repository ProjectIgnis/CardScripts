--Inventory of the Istrakan Hunter
function c210001510.initial_effect(c)
	--draw 2 card
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,210001509)
	e1:SetCost(c210001510.cost1)
	e1:SetTarget(c210001510.target1)
	e1:SetOperation(c210001510.operation1)
	c:RegisterEffect(e1)
	--back to hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,210001510)
	e2:SetCost(c210001510.cost2)
	e2:SetTarget(c210001510.target2)
	e2:SetOperation(c210001510.operation2)
	c:RegisterEffect(e2)
end
function c210001510.filter1(c)
	return (c:IsSetCard(0xf70) or c:IsSetCard(0xf71)) and c:IsDiscardable()
end
function c210001510.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210001510.filter1,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,c210001510.filter1,1,1,REASON_DISCARD+REASON_COST,nil)
end
function c210001510.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function c210001510.operation1(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function c210001510.filter2(c)
	return (c:IsSetCard(0xf70) or c:IsSetCard(0xf71)) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true,false)
end
function c210001510.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210001510.filter2,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,1,nil) end
	local g=Duel.SelectMatchingCard(tp,c210001510.filter2,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c210001510.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
function c210001510.operation2(e,tp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end