--女王親衛隊
-- Queen's Bodyguard
local s,id=GetID()
function s.initial_effect(c)
	--at limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetTarget(s.atlimit)
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
end
s.listed_series={0x14}
function s.atlimit(e,c)
	return c:IsFaceup() and c:IsSetCard(0x14)
end
