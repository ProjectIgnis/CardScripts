--巨人ゴーグル
--Goggle Golem
local s,id=GetID()
function s.initial_effect(c)
	Gemini.AddProcedure(c)
	--Original ATK becomes 2100
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(Gemini.EffectStatusCondition)
	e1:SetValue(2100)
	c:RegisterEffect(e1)
end