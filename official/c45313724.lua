--煉獄の釜 
--Void Cauldron
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	Duel.EnableGlobalFlag(GLOBALFLAG_SELF_TOGRAVE)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Banish to prevent destruction
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTarget(s.reptg)
	e1:SetValue(s.repval)
	e1:SetOperation(s.repop)
	c:RegisterEffect(e1)
	--Send to GY
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_SELF_TOGRAVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.sdcon)
	c:RegisterEffect(e2)
end
function s.dsdlv8filter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_SYNCHRO)
end
function s.dfilter(c,tp)
	return (s.dsdlv8filter(c) or (c:IsSetCard(SET_INFERNITY) and c:IsMonster())) and c:IsControler(tp) and c:IsReason(REASON_EFFECT)
end
function s.repfilter(c)
	return c:IsSetCard(SET_INFERNITY) and c:IsAbleToRemove() and aux.SpElimFilter(c,true)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.dfilter,1,nil,tp)
		and Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_GRAVE|LOCATION_MZONE,0,1,nil) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.repval(e,c)
	return c:IsControler(e:GetHandlerPlayer()) and (s.dsdlv8filter(c) or (c:IsSetCard(SET_INFERNITY) and c:IsMonster())) and c:IsReason(REASON_EFFECT)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_GRAVE|LOCATION_MZONE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
function s.sdcon(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)>0
end