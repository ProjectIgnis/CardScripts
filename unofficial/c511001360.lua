--Tidal Advantage
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return d and ((d:IsAttribute(ATTRIBUTE_WATER) and d:IsControler(tp)) or (a:IsAttribute(ATTRIBUTE_WATER) and a:IsControler(tp)))
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local s=Duel.GetAttacker()
	local o=Duel.GetAttackTarget()
	if o:IsAttribute(ATTRIBUTE_WATER) and o:IsControler(tp) then s,o=o,s end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(o:GetAttack()/2)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
	o:RegisterEffect(e1)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTarget(s.filter)
	e2:SetValue(1)
	Duel.RegisterEffect(e2,tp)
end
function s.filter(e,c)
	return c:IsAttribute(ATTRIBUTE_WATER)
end
