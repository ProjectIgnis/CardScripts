-- Deep Forest
-- scripted by: UnknownGuest
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	-- activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- cannot be attacked
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e2:SetTarget(s.tg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
function s.tg(e,c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_INSECT+RACE_BEAST+RACE_PLANT+RACE_BEASTWARRIOR)
end
