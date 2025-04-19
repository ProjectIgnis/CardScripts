--天輪の調律士
--Celestial Tuner
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,1)
	c:EnableReviveLimit()
	--cannot attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.notatk)
	c:RegisterEffect(e1)
	--atkup
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SET_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.condition)
	e2:SetValue(s.val)
	c:RegisterEffect(e2)
end
function s.notatk(e,c)
	return not c:IsType(TYPE_SYNCHRO)
end
function s.condition(e)
	local phase=Duel.GetCurrentPhase()
	return (phase==PHASE_DAMAGE or phase==PHASE_DAMAGE_CAL) and e:GetHandler():IsRelateToBattle()
end
function s.val(e,c)
	return c:GetAttack()*2
end