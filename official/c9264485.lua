--ホルスのしもべ
-- Horus' Servant
local s,id=GetID()
function s.initial_effect(c)
	--cannot be target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.tglimit)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
end
s.listed_series={0x3}
function s.tglimit(e,c)
	return c:IsFaceup() and c:IsSetCard(0x3)
end
