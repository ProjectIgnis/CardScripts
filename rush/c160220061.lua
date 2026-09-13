--レジェンド・パーティ
--Legendary Party
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Treated as a Legend Card in the hand or GY
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_IS_LEGEND)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	c:RegisterEffect(e0)
	--Atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.target)
	e1:SetValue(400)
	c:RegisterEffect(e1)
	--Cannot be destroyed by your opponent's effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--Gains 1000 ATK
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.condition)
	e3:SetValue(1000)
	c:RegisterEffect(e3)
end
function s.target(e,c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:GetBaseDefense()==300
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsLevel(10) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.condition(e)
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.indtg(e,c)
	return c:IsSpellTrap()
end