--地縛大神官
--Earthbound Linewalker
local s,id=GetID()
function s.initial_effect(c)
	--"Earthbound Immortal" monsters cannot be destroyed by their own effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_EARTHBOUND_IMMORTAL))
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
end
s.listed_series={SET_EARTHBOUND_IMMORTAL}
function s.efilter(e,re,rp,c)
	return re:GetOwner()==c
end