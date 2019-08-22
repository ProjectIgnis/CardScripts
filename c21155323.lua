--巨人ゴーグル
local s,id=GetID()
function s.initial_effect(c)
	aux.EnableGeminiAttribute(c)
	--change base attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(aux.IsGeminiState)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(2100)
	c:RegisterEffect(e1)
end
