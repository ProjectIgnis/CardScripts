-- Pollice Verso
--cleaned up by MLD
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
	-- If a card(s) is destroyed, its controller takes damage.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.damcon)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x19)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsReason,1,nil,REASON_BATTLE+REASON_EFFECT)
end
function s.damfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousControler(tp)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local dam1=eg:FilterCount(s.damfilter,nil,tp)*500
	local dam2=eg:FilterCount(s.damfilter,nil,1-tp)*500
	Duel.Damage(tp,dam1,REASON_EFFECT,true)
	Duel.Damage(1-tp,dam2,REASON_EFFECT,true)
	Duel.RDComplete()	
end
