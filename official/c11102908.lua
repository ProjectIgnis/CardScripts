--紫炎の霞城
--Shien's Castle of Mist
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--atk down
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg)
	e2:SetValue(-500)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SIX_SAMURAI}
function s.atkcon(e)
	local d=Duel.GetAttackTarget()
	return Duel.IsPhase(PHASE_DAMAGE_CAL) and d and d:IsSetCard(SET_SIX_SAMURAI)
end
function s.atktg(e,c)
	return c==Duel.GetAttacker()
end