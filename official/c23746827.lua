--億年の氷墓
--Million-Century Ice Prison
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Skip phase
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.skcon)
	e1:SetTarget(s.sktg)
	e1:SetOperation(s.skop)
	c:RegisterEffect(e1)
end
function s.skconfilter(c,tp)
	if c:IsReason(REASON_DESTROY) or not c:IsReason(REASON_EFFECT) then return false end
	local re=c:GetReasonEffect()
	return re:IsMonsterEffect() and re:GetHandlerPlayer()==1-tp
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
function s.skcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() and eg:IsExists(s.skconfilter,1,nil,tp)
end
function s.sktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	Duel.SetTargetParam(op)
end
function s.skop(e,tp,eg,ep,ev,re,r,rp)
	local op=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if op==0 and Duel.IsMainPhase() then
		--Skip the current phase
		Duel.SkipPhase(Duel.GetTurnPlayer(),Duel.GetCurrentPhase(),RESET_PHASE|PHASE_END,1)
	elseif op==1 then
		--Skip the Main Phase 1 of the opponent's next turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,3))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_SKIP_M1)
		e1:SetTargetRange(0,1)
		if Duel.IsTurnPlayer(1-tp) and Duel.IsPhase(PHASE_MAIN1) then
			local turn=Duel.GetTurnCount()
			e1:SetCondition(function() return Duel.GetTurnCount()~=turn end)
			e1:SetReset(RESET_PHASE|PHASE_MAIN1|RESET_OPPO_TURN,2)
		else
			e1:SetReset(RESET_PHASE|PHASE_MAIN1|RESET_OPPO_TURN,1)
		end
		Duel.RegisterEffect(e1,tp)
	end
end