--ヴァリュアブル・アーマー
--Grasschopper
local s,id=GetID()
function s.initial_effect(c)
	Gemini.AddProcedure(c)
	--Can attack all opponent monsters once each
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ATTACK_ALL)
	e1:SetCondition(Gemini.EffectStatusCondition)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end