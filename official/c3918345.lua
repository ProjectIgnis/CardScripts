--マジック・スライム
--Magical Reflect Slime
local s,id=GetID()
function s.initial_effect(c)
	Gemini.AddProcedure(c)
	--Reflect battle damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e1:SetCondition(Gemini.EffectStatusCondition)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end