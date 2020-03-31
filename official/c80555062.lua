--武神器－チカヘシ
local s,id=GetID()
function s.initial_effect(c)
	--
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.target)
	e1:SetCondition(s.con)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
s.listed_series={0x88}
function s.con(e)
	return e:GetHandler():IsDefensePos()
end
function s.target(e,c)
	return c~=e:GetHandler() and c:IsSetCard(0x88)
end
