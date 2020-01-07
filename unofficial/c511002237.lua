--Heliroid
local s,id=GetID()
function s.initial_effect(c)
	-- direct atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsCode,511002235))
	c:RegisterEffect(e2)
end
