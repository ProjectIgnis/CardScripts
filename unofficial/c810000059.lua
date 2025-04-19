-- Defending Sweeper
-- scripted by: UnknownGuest
local s,id=GetID()
function s.initial_effect(c)
	-- Increase Level
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
end
s.listed_names={450000110}
function s.condition(e)
	return Duel.IsEnvironment(450000110)
end