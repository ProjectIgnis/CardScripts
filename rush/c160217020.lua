--スパークハーツ・パッションマクマ
--Sparkhearts Passion Makma
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Ritual monster
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(id)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Gain Atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsCode,160003014))
	e2:SetValue(1300)
	c:RegisterEffect(e2)
	--Lose Atk
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsFaceup))
	e3:SetValue(s.val)
	c:RegisterEffect(e3)
end
function s.val(e,c)
	local g=Duel.GetMatchingGroup(Card.IsCode,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil,76103675,160301014)
	local ct=g:GetClassCount(Card.GetCode)
	return ct*-400
end