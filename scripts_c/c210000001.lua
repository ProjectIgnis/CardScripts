--Luckuriboh
function c210000001.initial_effect(c)
	--cool
	local e1=Effect.CreateEffect(c)
	e1:SetCountLimit(1,210000001)
	e1:SetCategory(CATEGORY_COIN)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c210000001.cost)
	e1:SetTarget(c210000001.tg)
	e1:SetOperation(c210000001.op)
	c:RegisterEffect(e1)
	--draw
	local e2=Effect.CreateEffect(c)
	e2:SetCountLimit(1,210000001+1)
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_COIN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c210000001.target)
	e2:SetOperation(c210000001.activate)
	c:RegisterEffect(e2)
end
function c210000001.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function c210000001.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
function c210000001.op(e,tp,eg,ep,ev,re,r,rp)
	local res=Duel.TossCoin(tp,1)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e1:SetCondition(c210000001.ccon1)
	e1:SetOperation(c210000001.cop1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetLabel(res)
	Duel.RegisterEffect(e1,tp)
end
function c210000001.ccon1(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
function c210000001.cop1(e,tp,eg,ep,ev,re,r,rp)
	local dam=Duel.GetBattleDamage(ep)
	local res=e:GetLabel()
	if res==1 then
		Duel.ChangeBattleDamage(ep,0)
		Duel.Recover(ep,dam,REASON_EFFECT)
	else
		Duel.ChangeBattleDamage(ep,2*dam)
	end
end
function c210000001.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
function c210000001.activate(e,tp,eg,ep,ev,re,r,rp)
	local res=Duel.TossCoin(tp,1)
	if res==1 then Duel.Draw(tp,1,REASON_EFFECT)
	else Duel.Draw(1-tp,1,REASON_EFFECT) end
end