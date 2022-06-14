--ゾンビ・カーニバル
--Zombie Carnival
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Increase ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.Race,RACE_ZOMBIE))
	e2:SetValue(s.value)
	c:RegisterEffect(e2)
	--Increase DEF
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end
function s.value(e,c)
	return 100*Duel.GetMatchingGroupCount(aux.FilterFaceupFunction(Card.IsRace,RACE_ZOMBIE),e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,nil)
end