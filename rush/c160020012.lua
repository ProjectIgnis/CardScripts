--昆遁忍虫 念珠のウツセミ
--Evasive Chaos Ninsect Rosary Cicada
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Pierce
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.target)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--No battle damage from your monsters with 0 ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(function(e,c) return c:IsRace(RACE_INSECT) end)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
function s.target(e,c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_INSECT) and c:HasContinuousRushEffect()
end