--エリア３３
--Area 33
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.actcond)
	c:RegisterEffect(e1)
	--Increase ATK of Reptile Normal monsters by 600
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.atkfilter)
	e2:SetValue(600)
	c:RegisterEffect(e2)
end
function s.rptfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsType(TYPE_NORMAL) and c:IsLevelBelow(3) and c:IsFaceup()
end
function s.actcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCountRush(s.rptfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)>1
end
function s.atkfilter(e,c)
	return c:IsRace(RACE_REPTILE) and c:IsType(TYPE_NORMAL)
end