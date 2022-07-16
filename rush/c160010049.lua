--バブル・キングダム
--Bubble Kingdom
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Increase ATK of Aqua Normal monsters by 200
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.aquanfilter)
	e2:SetValue(500)
	c:RegisterEffect(e2)
end
function s.aquanfilter(e,c)
	return c:IsRace(RACE_AQUA) and c:IsType(TYPE_NORMAL)
end