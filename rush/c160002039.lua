--世紀末獣機界ビーストギア・ワールド
--Apocalypse - Beast Gear World
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--ATK increase
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_BEASTWARRIOR+RACE_FIEND+RACE_MACHINE))
	e2:SetValue(300)
	c:RegisterEffect(e2)
	--ATK decrease
	local e3=e2:Clone()
	e3:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_DRAGON+RACE_SPELLCASTER+RACE_FAIRY))
	e3:SetValue(-300)
	c:RegisterEffect(e3)
end