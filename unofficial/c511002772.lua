--ガンバランサー
local s,id=GetID()
function s.initial_effect(c)
	--
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DOUBLE_XYZ_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end