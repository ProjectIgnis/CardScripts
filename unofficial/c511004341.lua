--Negate Attack (anime)
--scripted by andré
local s,id=GetID()
function s.initial_effect(c)
	--negate atack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,ev,eg,ep,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function s.operation(e,tp,ev,eg,ep,re,r,rp)
	if Duel.NegateAttack() then
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE,1)
	end
end