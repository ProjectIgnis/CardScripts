--デュアル・ランサー
local s,id=GetID()
function s.initial_effect(c)
	aux.EnableGeminiAttribute(c)
	--pierce
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetCondition(aux.IsGeminiState)
	c:RegisterEffect(e1)
end
