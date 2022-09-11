--エナジー・ブレイブ
--Energy Bravery
local s,id=GetID()
function s.initial_effect(c)
	--Gemini monsters cannot be destroyed by effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(_,c) return c:IsGeminiStatus() end)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end