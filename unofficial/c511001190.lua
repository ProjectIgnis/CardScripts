--Dragonroid
local s,id=GetID()
function s.initial_effect(c)
	--Type Machine
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetCondition(s.con)
	e2:SetValue(RACE_DRAGON)
	c:RegisterEffect(e2)
end
function s.con(e)
	return e:GetHandler():IsLocation(LOCATION_GRAVE)
end
