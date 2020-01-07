--Command Angel
local s,id=GetID()
function s.initial_effect(c)
	--atk def
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTarget(s.tg)
	e1:SetValue(400)
	c:RegisterEffect(e1)
end
function s.tg(e,c)
	return c:IsRace(RACE_FAIRY)
end
