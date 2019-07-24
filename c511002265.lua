--酒呑童子
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetCondition(s.atkcon)
	e1:SetValue(2000)
	c:RegisterEffect(e1)
end
function s.atkcon(e)
	local c=e:GetHandler()
	return c:GetPreviousLocation()==LOCATION_GRAVE 
		and (c:GetSummonType()&SUMMON_TYPE_SPECIAL)==SUMMON_TYPE_SPECIAL
end