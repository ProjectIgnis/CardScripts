-- It's a Toon World!
-- Skill activation
-- At the start of the Duel, place this card in your center Spell & Trap Zone and flip it over.
-- Effect
-- This card is treated as "Toon World".
local s,id=GetID()
function s.initial_effect(c)
	aux.AddContinuousSkillProcedure(c,300000100,false,true)
	--Activate
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e3)
	--change name
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetCode(EFFECT_CHANGE_CODE)
	e6:SetRange(0xff)
	e6:SetValue(15259703)
	c:RegisterEffect(e6)
end
