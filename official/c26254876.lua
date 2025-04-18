--デュアル・ランサー
--Gemini Lancer
local s,id=GetID()
function s.initial_effect(c)
	Gemini.AddProcedure(c)
	--Inflict piercing damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetCondition(Gemini.EffectStatusCondition)
	c:RegisterEffect(e1)
end