--六武院
--Temple of the Six
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_BUSHIDO)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--add counter
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--atk down
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetValue(s.val)
	c:RegisterEffect(e4)
end
s.listed_series={SET_SIX_SAMURAI}
s.counter_place_list={COUNTER_BUSHIDO}
function s.ctfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_SIX_SAMURAI)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.ctfilter,1,nil) then
		e:GetHandler():AddCounter(COUNTER_BUSHIDO,1)
	end
end
function s.val(e)
	return e:GetHandler():GetCounter(COUNTER_BUSHIDO)*-100
end