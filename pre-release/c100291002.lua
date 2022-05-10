--墓守の刻印
--Gravekeeper's Engraving
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Apply 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(function() return Duel.GetCurrentPhase()==PHASE_MAIN1 and not Duel.CheckPhaseActivity() end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.flagcheck(tp)
	return Duel.GetFlagEffect(tp,id+1)==0,Duel.GetFlagEffect(tp,id+2)==0,Duel.GetFlagEffect(tp,id+3)==0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1,b2,b3=s.flagcheck(tp)
	if chk==0 then return b1 or b2 or b3 end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local b1,b2,b3=s.flagcheck(tp)
	local op=aux.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b3,aux.Stringid(id,3)})
	if op==0 then return end
	local code=0
	if op==1 then
		code=EFFECT_CANNOT_ACTIVATE
	elseif op==2 then
		code=EFFECT_CANNOT_REMOVE
	else
		code=EFFECT_CANNOT_SPECIAL_SUMMON
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,op+3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(code)
	e1:SetTargetRange(1,1)
	if op==1 then
		e1:SetValue(function(_,re) return re:GetActivateLocation()==LOCATION_GRAVE end)
	else
		e1:SetTarget(function(_,c) return c:IsLocation(LOCATION_GRAVE) end)
	end
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	Duel.RegisterEffect(e1,tp)
	Duel.RegisterFlagEffect(tp,id+op,RESET_PHASE+PHASE_END,0,1)
end