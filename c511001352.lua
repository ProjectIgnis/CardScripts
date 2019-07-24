--Insect Garden
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--control
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SET_CONTROL)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.filter)
	e2:SetValue(s.ctval)
	c:RegisterEffect(e2)
end
function s.filter(e,c)
	return c:IsFaceup() and c:IsLevelBelow(4) and c:IsRace(RACE_INSECT) and c:GetOwner()==e:GetHandlerPlayer()
end
function s.ctval(e,c)
	return 1-e:GetHandlerPlayer() 
end
