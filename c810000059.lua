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
function s.filter(c)
	return c:IsFaceup() and c:IsCode(450000110)
end
function s.condition(e)
	return Duel.IsExistingMatchingCard(s.filter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		or Duel.GetEnvironment()==450000110
end
