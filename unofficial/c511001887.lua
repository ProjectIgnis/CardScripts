--光のピラミッド
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Doom Virus (Faceup)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_SZONE)	
	e2:SetOperation(s.banop)
	c:RegisterEffect(e2)
	--check
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_MSET)
	e3:SetOperation(s.chkop)
	c:RegisterEffect(e3)
end
function s.filter(c)
	return c:IsFaceup() and (c:IsAttribute(ATTRIBUTE_DIVINE) or c:IsRace(RACE_DIVINE) or c:IsRace(RACE_CREATORGOD) 
		or (c:GetOriginalRace()&RACE_DIVINE)==RACE_DIVINE or (c:GetOriginalRace()&RACE_CREATORGOD)==RACE_CREATORGOD 
		or (c:GetOriginalAttribute()&ATTRIBUTE_DIVINE)==ATTRIBUTE_DIVINE) and c:IsAbleToRemove()
end
function s.filter2(c)
	return c:IsFacedown() and (c:IsAttribute(ATTRIBUTE_DIVINE) or c:IsRace(RACE_DIVINE) or c:IsRace(RACE_CREATORGOD) 
		or (c:GetOriginalRace()&RACE_DIVINE)==RACE_DIVINE or (c:GetOriginalRace()&RACE_CREATORGOD)==RACE_CREATORGOD 
		or (c:GetOriginalAttribute()&ATTRIBUTE_DIVINE)==ATTRIBUTE_DIVINE) and c:IsAbleToRemove()
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	local conf=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if #conf>0 then
		Duel.ConfirmCards(tp,conf)
		Duel.Remove(conf,POS_FACEUP,REASON_EFFECT)
	end
end
function s.chkop(e,tp,eg,ep,ev,re,r,rp)
	local conf=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE,POS_FACEDOWN)
	if #conf>0 then
		Duel.ConfirmCards(tp,conf)
	end
end
