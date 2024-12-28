--歯車街区
--Gear Section
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.tg)
	e2:SetValue(200)
	c:RegisterEffect(e2)
	--decrease tribute
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DECREASE_TRIBUTE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
	e3:SetTarget(s.tribtg)
	e3:SetValue(s.val)
	c:RegisterEffect(e3)
end
function s.tg(e,c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_MACHINE)
end
function s.tribtg(e,c)
	return s.tg(e,c) and c:GetAttack()==c:GetDefense()
end
function s.val(e,c)
	local tp=e:GetHandlerPlayer()
	return Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsOriginalCode,160212014),tp,LOCATION_FZONE,LOCATION_FZONE,nil)
end