--インヴェルズの歩哨
local s,id=GetID()
function s.initial_effect(c)
	--cannot trigger
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_TRIGGER)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.condition)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
end
function s.condition(e)
	return e:GetHandler():IsAttackPos()
end
function s.target(e,c)
	return c:GetLevel()>=5 and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
