--ゴーストリック・ミュージアム (Action Field)
--Ghostrick Museum (Action Field)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--cannot attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.ftarget)
	c:RegisterEffect(e2)
	--atklimit
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetValue(s.bttg)
	c:RegisterEffect(e3)
	--direct attack
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DIRECT_ATTACK)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(s.dirtg)
	c:RegisterEffect(e4)
	--pos
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCode(EVENT_BATTLE_DAMAGE)
	e5:SetOperation(s.regop)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetRange(LOCATION_FZONE)
	e6:SetCode(EVENT_DAMAGE_STEP_END)
	e6:SetCondition(s.poscon)
	e6:SetOperation(s.posop)
	e6:SetLabelObject(e5)
	c:RegisterEffect(e6)
end
s.af="a"
function s.bttg(e,c)
	return c:IsFacedown()
end
function s.dirtg(e,c)
	return not Duel.IsExistingMatchingCard(Card.IsFaceup,c:GetControler(),0,LOCATION_MZONE,1,nil)
end
function s.ftarget(e,c)
	return not c:IsSetCard(0x8d)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE,0,1)
	eg:GetFirst():RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE,0,1)
end
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
function s.filter(c)
	return c:GetFlagEffect(id+1)>0
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end
