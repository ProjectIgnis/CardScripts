--開運ミラクルストーン (VG)
--Miracle Stone (VG)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--atk up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x12e))
	e2:SetValue(s.val)
	c:RegisterEffect(e2)
	--attack res
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(s.atktg)
	c:RegisterEffect(e3)
end
function s.val(e,c)
	return Duel.GetMatchingGroupCount(aux.FilterFaceupFunction(Card.IsSetCard,0x12e),c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,nil)*1000
end
function s.atktg(e,c)
	return c:IsStatus(STATUS_SUMMON_TURN) and c:IsSetCard(0x12e) and (c:GetSummonType()&SUMMON_TYPE_SPECIAL)~=0 
end
