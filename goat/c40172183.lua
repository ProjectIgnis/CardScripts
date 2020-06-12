--狭き通路
--Narrow Pass (GOAT)
--It allows the player to perform only other 2 normal summons after the card resolved
--Until the card is removed from the field or negated
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetTarget(s.sumlimit)
	e2:SetLabel(0)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_SUMMON)
	e3:SetOperation(s.sumop)
	c:RegisterEffect(e3)
	s[c]={}
	s[c][0]=0
	s[c][1]=0
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	s[e:GetHandler()][tp]=0
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<=2
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)<=2
end
function s.sumlimit(e,c,sp,st)
	return s[e:GetHandler()][sp]>=2
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	s[e:GetHandler()][rp]=s[e:GetHandler()][rp]+1
end
