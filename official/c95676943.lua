--絶滅の定め
--Extinction on Schedule
local s,id=GetID()
function s.initial_effect(c)
	--Make players send all cards they control to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCondition(function() return Duel.IsMainPhase() end)
	e1:SetCost(Cost.PayLP(2000))
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:SetTurnCounter(0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE|PHASE_BATTLE)
	e1:SetCountLimit(1)
	e1:SetOperation(s.tgop)
	e1:SetReset(RESET_PHASE|PHASE_BATTLE,3)
	Duel.RegisterEffect(e1,tp)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==3 then
		local g1=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0)
		local g2=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
		Duel.SendtoGrave(g1,REASON_RULE,PLAYER_NONE,tp)
		Duel.SendtoGrave(g2,REASON_RULE,PLAYER_NONE,1-tp)
	end
end