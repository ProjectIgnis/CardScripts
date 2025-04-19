--ダブルフィン・シャーク
local s,id=GetID()
function s.initial_effect(c)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DOUBLE_XYZ_MATERIAL)
	e2:SetOperation(s.tgval)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
function s.tgval(e,c)
	return c:IsAttribute(ATTRIBUTE_WATER)
end