--サンライズ・ガードナー
--Dawnbreak Gardna
local s,id=GetID()
function s.initial_effect(c)
	Gemini.AddProcedure(c)
	--Original DEF becomes 2300
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_SET_BASE_DEFENSE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(Gemini.EffectStatusCondition)
	e1:SetValue(2300)
	c:RegisterEffect(e1)
end