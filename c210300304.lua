--Youkai Slasher, Tanba
function c210300304.initial_effect(c)
	aux.EnableDualAttribute(c)
	--atk up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(aux.IsDualState)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) return c:GetCode()>210300300 and c:GetCode()<210300400 end)
	e1:SetValue(300)
	c:RegisterEffect(e1)
	--on release
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetOperation(c210300304.checkop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_RELEASE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCondition(c210300304.rcon)
	e3:SetTarget(c210300304.rtg)
	e3:SetOperation(c210300304.rop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	--remove
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(210300304,1))
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLED)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c210300304.rmcon)
	e4:SetTarget(c210300304.rmtg)
	e4:SetOperation(c210300304.rmop)
	c:RegisterEffect(e4)
end
function c210300304.checkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsDisabled() and c:IsDualState() and c:IsReason(REASON_RELEASE) then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
function c210300304.rcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()==1
end
function c210300304.rtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,0,LOCATION_ONFIELD,2,nil,TYPE_SPELL+TYPE_TRAP) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsType,tp,0,LOCATION_ONFIELD,2,2,nil,TYPE_SPELL+TYPE_TRAP)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function c210300304.rop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	Duel.Destroy(g,REASON_EFFECT)
end
function c210300304.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not e:GetHandler():IsDualState() then return end
	local ac=Duel.GetAttacker()
	local bc=Duel.GetAttackTarget()
	if not (ac:GetCode()>210300300 and ac:GetCode()<210300400) then ac,bc=bc,ac end
	if not (ac:GetCode()>210300300 and ac:GetCode()<210300400) then return end
	e:SetLabelObject(bc)
	return ac and bc and
		(ac:GetCode()>210300300 and ac:GetCode()<210300400 and not ac:IsStatus(STATUS_BATTLE_DESTROYED) and bc:IsStatus(STATUS_BATTLE_DESTROYED)) or
		(bc:GetCode()>210300300 and bc:GetCode()<210300400 and not bc:IsStatus(STATUS_BATTLE_DESTROYED) and ac:IsStatus(STATUS_BATTLE_DESTROYED))
end
function c210300304.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetLabelObject(),1,0,0)
end
function c210300304.rmop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc:IsRelateToBattle() and bc:IsAbleToRemove() then
		Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)
	end
end
