--砂の砦
--Sand Fortress
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.atkcon)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	--Trap Spell
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_BECOME_QUICK)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
	e4:SetDescription(aux.Stringid(id,0))
	c:RegisterEffect(e4)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttackTarget()==nil and ep==tp
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetFlagEffect(id)==0 then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
		e:SetLabel(0)
	end
	local dam=e:GetLabel()
	Duel.ChangeBattleDamage(tp,0)
	e:SetLabel(dam+ev)
	if e:GetLabel()>=3000 then
		Duel.Destroy(c,REASON_EFFECT)
	end
end