--Time Wave
--concept by Gideon
--scripted by Larry126
function c210660016.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c210660016.condition)
	e1:SetOperation(c210660016.operation)
	c:RegisterEffect(e1)
end
function c210660016.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and not Duel.CheckPhaseActivity()
		and not Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
end
function c210660016.operation(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_SKIP_M1)
	e1:SetTargetRange(1,1)
	e1:SetReset(RESET_PHASE+PHASE_MAIN1,5)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SKIP_M2)
	e2:SetReset(RESET_PHASE+PHASE_MAIN2,5)
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_SKIP_BP)
	e3:SetReset(RESET_PHASE+PHASE_BATTLE,5)
	Duel.RegisterEffect(e3,tp)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_CANNOT_BP)
	e4:SetReset(RESET_PHASE+PHASE_END,6)
	Duel.RegisterEffect(e4,tp)
end