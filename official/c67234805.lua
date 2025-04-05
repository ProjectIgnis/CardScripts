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
	--Place 1 Spellstone Counter each time a monster effect is activated
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
	--Monsters on the field cannot activate their effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_TRIGGER)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetCondition(function(e) return e:GetHandler():GetCounter(0x16)==2 end)
	c:RegisterEffect(e3)
	--Negate the effects of all monsters on the field
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DISABLE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetCondition(function(e) return e:GetHandler():GetCounter(0x16)==2 end)
	e4:SetTarget(function(e,c) return c:IsType(TYPE_EFFECT) end)
	c:RegisterEffect(e4)
	--Remove all Spellstone Counters from this card during the End Phase
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(function(e) return e:GetHandler():GetCounter(0x16)>0 end)
	e5:SetOperation(s.rmop)
	c:RegisterEffect(e5)
end
s.counter_place_list={0x16}
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsMonsterEffect() and e:GetHandler():GetFlagEffect(1)>0 then
		e:GetHandler():AddCounter(0x16,1)
	end
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveCounter(tp,0x16,e:GetHandler():GetCounter(0x16),REASON_EFFECT)
end