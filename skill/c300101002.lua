--Straight to the Grave
--Skill activation
--At the start of the Duel, place this card in your Field Zone and flip it over.
--Effect
--All Dinosaur, Zombie, and Rock monsters on the field gain 200 ATK/DEF.
local s,id=GetID()
function s.initial_effect(c)
	aux.AddFieldSkillProcedure(c,2,false)
	--Activate
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e3)
	--Atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_DINOSAUR+RACE_ZOMBIE+RACE_ROCK))
	e2:SetValue(200)
	c:RegisterEffect(e2)
	--Def
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end
