--バルーン・リザード
--Balloon Lizard (GOAT)
--Battle destroyed registers while the monster is on field
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x29)
	--counter
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.addccon)
	e1:SetTarget(s.addct)
	e1:SetOperation(s.addc)
	c:RegisterEffect(e1)
	--damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLED)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCondition(s.damcon2)
	e3:SetTarget(s.damtg2)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(s.damcon)
	e4:SetTarget(s.damtg)
	e4:SetLabelObject(e2)
	c:RegisterEffect(e4)
end
function s.addccon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function s.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x29)
end
function s.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x29,1)
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsBattleDestroyed() then return end
	local ct=c:GetCounter(0x29)
	e:SetLabel(ct)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsBattleDestroyed() then return false end
	local ct=e:GetLabelObject():GetLabel()
	e:SetLabel(ct)
	return ct>0
end
function s.damcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsBattleDestroyed() then return false end
	local ct=c:GetCounter(0x29)
	e:SetLabel(ct)
	return ct>0
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(rp)
	Duel.SetTargetParam(e:GetLabel()*400)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,rp,e:GetLabel()*400)
end
function s.damtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local other=Duel.GetAttacker()
	if other==e:GetHandler() then other=Duel.GetAttackTarget() end
	Duel.SetTargetPlayer(other:GetControler())
	Duel.SetTargetParam(e:GetLabel()*400)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,other:GetControler(),e:GetLabel()*400)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
