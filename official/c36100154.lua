--アマゾネスの闘志
--Amazoness Fighting Spirit
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--"Amazoness" monsters gain 1000 ATK during Damage Calculation
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
end
s.listed_series={SET_AMAZONESS}
function s.atkcon(e)
	s[0]=false
	return Duel.IsPhase(PHASE_DAMAGE_CAL) and Duel.GetAttackTarget()
end
function s.atktg(e,c)
	return c==Duel.GetAttacker() and c:IsSetCard(SET_AMAZONESS)
end
function s.atkval(e,c)
	local d=Duel.GetAttackTarget()
	if s[0] or c:GetAttack()<d:GetAttack() then
		s[0]=true
		return 1000
	else return 0 end
end