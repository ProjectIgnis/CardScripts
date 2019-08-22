--ヘルカイザー・ドラゴン
local s,id=GetID()
function s.initial_effect(c)
	aux.EnableGeminiAttribute(c)
	--double atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(1)
	e1:SetCondition(aux.IsGeminiState)
	c:RegisterEffect(e1)
end