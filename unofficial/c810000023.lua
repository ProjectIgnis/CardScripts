-- Labor Pain
-- scripted by: UnknownGuest
local s,id=GetID()
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- cost
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SUMMON_COST)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
	e2:SetTarget(s.sumtg)
	e2:SetCost(s.ccost)
	e2:SetOperation(s.acop)
	c:RegisterEffect(e2)
end
function s.sumtg(e,c)
	return c:IsType(TYPE_MONSTER)
end
function s.ccost(e,c,tp)
	return Duel.CheckLPCost(tp,1000)
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	Duel.PayLPCost(tp,1000)
end