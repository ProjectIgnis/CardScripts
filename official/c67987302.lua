--地縛大神官
local s,id=GetID()
function s.initial_effect(c)
	--indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x21))
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
end
s.listed_series={0x21}
function s.efilter(e,re,rp,c)
	return re:GetOwner()==c
end
