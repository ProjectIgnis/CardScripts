--Elemental HERO Absolute Zero (manga)
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0x8),aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_WATER))
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.value)
	c:RegisterEffect(e1)
end
s.material_setcode=0x8
function s.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
function s.value(e,c)
	return Duel.GetMatchingGroupCount(s.filter,0,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())*500
end