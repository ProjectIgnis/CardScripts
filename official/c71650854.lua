--半魔導帯域
--Magical Mid-Breaker Field
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
	--Prevent effect target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.indcon)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	--Prevent destruction by opponent's effect
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetValue(s.tgoval)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e5:SetTargetRange(0,LOCATION_MZONE)
	e5:SetValue(s.tgovalue)
	c:RegisterEffect(e5)
	--cannot set/activate
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_CANNOT_SSET)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetRange(LOCATION_FZONE)
	e6:SetTargetRange(1,0)
	e6:SetTarget(s.setlimit)
	c:RegisterEffect(e6)
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_CANNOT_ACTIVATE)
	e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e7:SetRange(LOCATION_FZONE)
	e7:SetTargetRange(1,0)
	e7:SetValue(s.actlimit)
	c:RegisterEffect(e7)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
		and (not Duel.CheckPhaseActivity() or (Duel.GetFlagEffect(tp,CARD_MAGICAL_MIDBREAKER)>0 and Duel.GetCurrentChain()==1))
end
function s.indcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
function s.tgoval(e,re,rp)
	return rp~=1-e:GetHandlerPlayer() and not re:GetHandler():IsImmuneToEffect(e)
end
function s.tgovalue(e,re,rp)
	return rp~=1-e:GetHandlerPlayer()
end
function s.setlimit(e,c,tp)
	return c:IsType(TYPE_FIELD)
end
function s.actlimit(e,re,tp)
	return re:IsActiveType(TYPE_FIELD) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end