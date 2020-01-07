--Cosmic Space
-- !counter 0x1109 Life Star Counter
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--remove counter
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	--add counter on summoned
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetOperation(s.ctop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EVENT_FLIP)
	c:RegisterEffect(e5)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x1109,tc:GetLevel(),REASON_EFFECT)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SELF_DESTROY)
		e1:SetCondition(s.descon)
		e1:SetLabelObject(e:GetHandler())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
function s.descon(e)
	if e:GetHandler():GetCounter(0x1109)>0 then return false end
	local tc1=Duel.GetFieldCard(0,LOCATION_SZONE,5)
	local tc2=Duel.GetFieldCard(1,LOCATION_SZONE,5)
	if tc1 and tc1==e:GetLabelObject() and tc1:IsFaceup() and not tc1:IsDisabled() then return true
	elseif tc2 and tc2==e:GetLabelObject() and tc2:IsFaceup() and not tc2:IsDisabled() then return true
	else return false
	end
end
function s.rmcfilter(c)
	return c:GetCounter(0x1109)~=0
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.rmcfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		tc:RemoveCounter(tp,0x1109,1,REASON_EFFECT)
		tc=g:GetNext()
	end
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsFaceup,nil)
	local tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x1109,tc:GetLevel(),REASON_EFFECT)	
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SELF_DESTROY)
		e1:SetCondition(s.descon)
		e1:SetLabelObject(e:GetHandler())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
