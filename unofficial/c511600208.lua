--モーリーの盾
--Morley's Shield
--scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_CAL)
	e1:SetHintTiming(TIMING_DAMAGE_CAL,TIMING_DAMAGE_CAL)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	--Negate damage
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9106362,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetCondition(s.dmcon)
	e2:SetTarget(s.dmtg)
	e2:SetOperation(s.dmop)
	c:RegisterEffect(e2)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local b=Duel.CheckEvent(EVENT_PRE_DAMAGE_CALCULATE,true)
	local c=e:GetHandler()
	if b and s.dmcon(e,tp,eg,ep,ev,re,r,rp) and Duel.SelectEffectYesNo(tp,c) then
		c:RegisterFlagEffect(id,RESET_PHASE+PHASE_END+RESET_EVENT+RESETS_STANDARD,0,1)
		c:RegisterFlagEffect(0,RESET_CHAIN,EFFECT_FLAG_CLIENT_HINT,1,0,65)
		s.dmtg(e,tp,eg,ep,ev,re,r,rp,1)
		e:SetOperation(s.dmop)
	else
		e:SetProperty(0)
		e:SetOperation(nil)
	end
end
function s.dmcon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	local tc=a:IsControler(tp) and a or d:IsControler(tp) and d
	return d and tc and tc:GetSequence()<5 and e:GetHandler():GetFlagEffect(id)==0
end
function s.dmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(id,RESET_PHASE+PHASE_END+RESET_EVENT+RESETS_STANDARD,0,1)
end
function s.dmop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e1:SetOperation(s.damop)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	Duel.RegisterEffect(e1,tp)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(tp,0)
end