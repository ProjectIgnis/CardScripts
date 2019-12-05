--能力吸収石
--Powersink Stone
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x16)
	c:SetCounterLimit(0x16,2)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Add counter
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(aux.chainreg)
	c:RegisterEffect(e2)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	--negate
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_TRIGGER)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetCondition(s.discon)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DISABLE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetCondition(s.discon)
	e4:SetTarget(s.distg)
	c:RegisterEffect(e4)
	--remove counter
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(s.rmcon)
	e5:SetOperation(s.rmop)
	c:RegisterEffect(e5)
end
s.counter_place_list={0x16}
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsActiveType(TYPE_MONSTER) and e:GetHandler():GetFlagEffect(1)>0 then
		e:GetHandler():AddCounter(0x16,1)
	end
end
function s.discon(e)
	return e:GetHandler():GetCounter(0x16)==2
end
function s.distg(e,c)
	return c:IsType(TYPE_EFFECT)
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x16)>0
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveCounter(tp,0x16,e:GetHandler():GetCounter(0x16),REASON_EFFECT)
end
