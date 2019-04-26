--王家の伯爵
--Pharaonic Earl
--Scripted by Eerie Code
function c120401055.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_DARK),1,1)
	--Negate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(120401055,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c120401055.negcon)
	e1:SetCost(c120401055.negcost)
	e1:SetTarget(c120401055.negtg)
	e1:SetOperation(c120401055.negop)
	c:RegisterEffect(e1)
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CUSTOM+120401055)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c120401055.atkop)
	c:RegisterEffect(e2)
	--chain check
	if not c120401055.global_flag then
		c120401055.global_flag=true
		c120401055[0]=0
		c120401055[1]=0
		local g1=Effect.CreateEffect(c)
		g1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		g1:SetCode(EVENT_CHAINING)
		g1:SetOperation(c120401055.chainop1)
		Duel.RegisterEffect(g1,tp)
		local g2=Effect.CreateEffect(c)
		g2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		g2:SetCode(EVENT_CHAIN_SOLVED)
		g2:SetOperation(c120401055.chainop2)
		Duel.RegisterEffect(g2,tp)
	end
end
function c120401055.negcon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or e:GetHandler():IsStatus(STATUS_CHAINING) or not Duel.IsChainNegatable(ev) then return false end
	if not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not re:IsActiveType(TYPE_TRAP) or rp==tp then return false end
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_SPECIAL_SUMMON)
	return ex
end
function c120401055.cfilter(c)
	return not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
function c120401055.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,c120401055.cfilter,1,nil) end
	local g=Duel.SelectReleaseGroup(tp,c120401055.cfilter,1,1,nil)
	Duel.Release(g,REASON_COST)
end
function c120401055.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsAbleToRemove() end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
	end
end
function c120401055.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
function c120401055.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetLinkedGroup()
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e1)
	end
end
function c120401055.chainop1(e,tp,eg,ep,ev,re,r,rp)
	c120401055[rp]=c120401055[rp]+1
end
function c120401055.chainop2(e,tp,eg,ep,ev,re,r,rp)
	if c120401055[1-tp]>=2 then
		Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+120401055,re,r,rp,0,0)
	end
	c120401055[0]=0
	c120401055[1]=0
end
