--E・HERO アナザー・ネオス
local s,id=GetID()
function s.initial_effect(c)
	aux.EnableGeminiAttribute(c)
	--code
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetCondition(aux.IsGeminiState)
	e1:SetValue(CARD_NEOS)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_NEOS}
