--It's a Toon World!
--Skill activation
--At the start of the Duel, place this card in your center Spell & Trap Zone and flip it over.
--Effect
--This card is treated as "Toon World".
local s,id=GetID()
function s.initial_effect(c)
	aux.AddContinuousSkillProcedure(c,2,false,true)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--change name
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CHANGE_CODE)
	e2:SetRange(0xff)
	e2:SetValue(15259703)
	c:RegisterEffect(e2)
end
