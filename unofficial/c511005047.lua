--Final Life Gardna
--original script by Shad3
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(s.cd)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.cd(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetBattleDamage(tp)>=Duel.GetLP(tp)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	e1:SetOperation(s.zero_op)
	Duel.RegisterEffect(e1,tp)
	Duel.SetLP(tp,100)
	Duel.SkipPhase(Duel.GetTurnPlayer(),PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE,1)
end
function s.zero_op(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(tp,0)
end