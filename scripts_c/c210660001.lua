--Wicked Fortune
function c210660001.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c210660001.target)
	e1:SetOperation(c210660001.activate)
	c:RegisterEffect(e1)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(aux.exccon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c210660001.drtg)
	e2:SetOperation(c210660001.drop)
	c:RegisterEffect(e2)
end
function c210660001.gfilter(c)
	return c:IsFaceup() and c:IsCode(21208154,57793869,62180201)
end
function c210660001.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ct=Duel.GetMatchingGroupCount(c210660001.gfilter,tp,LOCATION_MZONE,0,nil)*2
		e:SetLabel(ct)
		return ct>0 and Duel.IsPlayerCanDraw(tp,ct)
	end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(e:GetLabel())
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,e:GetLabel())
end
function c210660001.activate(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local ct=Duel.GetMatchingGroupCount(c210660001.gfilter,tp,LOCATION_MZONE,0,nil)*2
	Duel.Draw(p,ct,REASON_EFFECT)
end
function c210660001.gfilter2(c)
	return c:IsFaceup() and (c:IsSetCard(0xf66) or c:IsCode(21208154,57793869,62180201))
end
function c210660001.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ct=Duel.GetMatchingGroupCount(c210660001.gfilter2,tp,LOCATION_MZONE,0,nil)
		e:SetLabel(ct)
		return ct>0 and Duel.IsPlayerCanDraw(tp,ct)
	end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(e:GetLabel())
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,e:GetLabel())
end
function c210660001.drop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local ct=Duel.GetMatchingGroupCount(c210660001.gfilter2,tp,LOCATION_MZONE,0,nil)*1
	Duel.Draw(p,ct,REASON_EFFECT)
end
