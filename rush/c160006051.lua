-- 獣戦場のバリア
--Beast Battlefield Barrier
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--ATK decrease
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsMonster))
	e2:SetValue(-200)
	c:RegisterEffect(e2)
	--DEF increase
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetTarget(s.target)
	e3:SetValue(400)
	c:RegisterEffect(e3)
end
function s.target(e,c)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_BEAST)
end