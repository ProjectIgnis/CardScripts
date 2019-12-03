--洗脳光線
--Brainwashing Beam
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetLabelObject(e1)
	e2:SetCondition(aux.PersistentTgCon)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	--control
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SET_CONTROL)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(aux.PersistentTargetFilter)
	e3:SetValue(s.tg)
	c:RegisterEffect(e3)
	--destroy
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EFFECT_SELF_DESTROY)
	e4:SetCondition(s.descon)
	c:RegisterEffect(e4)
	--destroy2
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetCondition(s.descon2)
	e5:SetOperation(s.desop2)
	c:RegisterEffect(e5)
	--remove counter
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCode(EVENT_PHASE+PHASE_END)
	e6:SetCountLimit(1)
	e6:SetCondition(s.rccon)
	e6:SetOperation(s.rcop)
	c:RegisterEffect(e6)
end
s.counter_list={0x100e}
function s.filter(c)
	return c:GetCounter(0x100e)>0 and c:IsControlerCanBeChanged()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS):GetFirst()
	if c:IsRelateToEffect(re) and tc and tc:IsFaceup() and tc:GetCounter(0x100e)>0 and tc:IsRelateToEffect(re) then
		c:SetCardTarget(tc)
	end
end
function s.tg(e,c)
	return e:GetHandlerPlayer()
end
function s.descon(e)
	local c=e:GetHandler()
	if c:GetCardTargetCount()==0 then return false end
	return c:GetFirstCardTarget():GetCounter(0x100e)==0
end
function s.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsReason(REASON_DESTROY)
end
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
function s.rccon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and e:GetHandler():GetFirstCardTarget()
end
function s.rcop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	tc:RemoveCounter(tp,0x100e,1,REASON_EFFECT)
	Duel.RaiseEvent(e:GetHandler(),EVENT_REMOVE_COUNTER+0x100e,e,REASON_EFFECT,tp,tp,1)
end
