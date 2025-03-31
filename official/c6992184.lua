--Pendulum Encore
--Pendulum Encore
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.pencon)
	e1:SetCost(s.pencost)
	e1:SetTarget(s.pentg)
	e1:SetOperation(s.penop)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		s.should_check=false
		s.exclude_card=nil
		local geff=Effect.CreateEffect(c)
		geff:SetType(EFFECT_TYPE_FIELD)
		geff:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		geff:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		geff:SetTargetRange(1,1)
		geff:SetTarget(function(e,c)
			if s.should_check or s.exclude_card then
				return c==s.exclude_card or not c:IsType(TYPE_PENDULUM)
			end
			return false
		end)
		Duel.RegisterEffect(geff,0)
	end)
end
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(1-tp) and Duel.IsMainPhase()
end
function s.filter(c,tp)
	s.exclude_card=c
	local res=c:IsDiscardable() and Duel.IsPlayerCanPendulumSummon(tp)
	s.exclude_card=nil
	return res
end
function s.pencost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==100 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,e:GetHandler(),tp) end
		s.should_check=true
		local res=Duel.IsPlayerCanPendulumSummon(tp)
		s.should_check=nil
		return res
	end
	e:SetLabel(0)
	Duel.DiscardHand(tp,s.filter,1,1,REASON_COST|REASON_DISCARD,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA|LOCATION_HAND)
end
function s.addreset(c)
	s.should_check=true
	local eff=Effect.CreateEffect(c)
	eff:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	eff:SetCode(EVENT_CHAIN_END)
	eff:SetOperation(function(e) e:Reset() s.should_check=false end)
	Duel.RegisterEffect(eff,0)
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	Duel.PendulumSummon(tp)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		s.addreset(e:GetHandler())
		--indes and can't activate
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetTargetRange(LOCATION_PZONE,0)
		e1:SetValue(aux.indsval)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_ACTIVATE)
		e2:SetValue(1)
		Duel.RegisterEffect(e2,tp)
		--return to deck
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetCountLimit(1)
		e3:SetOperation(s.retop)
		e3:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e3,tp)
	end
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	if #g>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end