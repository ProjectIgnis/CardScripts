--虫媒花の園
--Insect Garden
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(function() Duel.AdjustInstantly() end)
	c:RegisterEffect(e1)
	--Give control of all Level 4 or lower Insect monsters you control to your opponent
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetOperation(s.ctrlop)
	c:RegisterEffect(e2)
end
function s.ctrlfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(4) and c:IsRace(RACE_INSECT) and c:IsControlerCanBeChanged()
end
function s.ctrlop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.ctrlfilter,tp,LOCATION_MZONE,0,nil)
	Duel.GetControl(g,1-tp)
end
