--チューンド・マジシャン
local s,id=GetID()
function s.initial_effect(c)
	aux.EnableGeminiAttribute(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(aux.IsGeminiState)
	e1:SetValue(TYPE_TUNER)
	c:RegisterEffect(e1)
end

