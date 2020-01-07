--Slow Life
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
	--disable summon (player)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCondition(s.con1)
	e2:SetTargetRange(1,0)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_MSET)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCondition(s.con2)
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	c:RegisterEffect(e4)
	--disable summon (opponent)
	local e5=e2:Clone()
	e5:SetCondition(s.con3)
	e5:SetTargetRange(0,1)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_CANNOT_MSET)
	c:RegisterEffect(e6)
	local e7=e4:Clone()
	e7:SetCondition(s.con4)
	e7:SetTargetRange(0,1)
	c:RegisterEffect(e7)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function s.con1(e)
	return Duel.GetActivityCount(e:GetHandlerPlayer(),ACTIVITY_SPSUMMON)>0
end
function s.con2(e)
	return Duel.GetActivityCount(e:GetHandlerPlayer(),ACTIVITY_NORMALSUMMON)>0
end
function s.con3(e)
	return Duel.GetActivityCount(1-e:GetHandlerPlayer(),ACTIVITY_SPSUMMON)>0
end
function s.con4(e)
	return Duel.GetActivityCount(1-e:GetHandlerPlayer(),ACTIVITY_NORMALSUMMON)>0
end
