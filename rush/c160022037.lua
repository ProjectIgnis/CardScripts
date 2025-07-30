--なほいとをかしかなひめ
--Ever-Grace Princess Kana
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Ritual monster
	c:EnableReviveLimit()
	--Name becomes "Grace Princess Kana"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_GRAVE|LOCATION_MZONE)
	e1:SetValue(160004013)
	c:RegisterEffect(e1)
	--Atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.target)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_LEVEL)
	e3:SetValue(5)
	c:RegisterEffect(e3)
end
function s.target(e,c)
	return c:IsRace(RACE_AQUA) and c:IsAttribute(ATTRIBUTE_LIGHT)
end