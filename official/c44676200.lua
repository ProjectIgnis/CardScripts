--ヒーローバリア
local s,id=GetID()
function s.initial_effect(c)
	--negate attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={0x3008}
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x3008)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and Duel.GetCurrentPhase()<PHASE_MAIN2
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetAttacker() then Duel.NegateAttack()
	else
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_ATTACK_ANNOUNCE)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetOperation(s.disop)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateAttack()
	e:Reset()
end
