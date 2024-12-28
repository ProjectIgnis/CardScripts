--支援ユニット－クマミミ
--Support Unit - Kumamimi
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.target)
	e1:SetValue(500)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
end
function s.target(e,c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH)
end