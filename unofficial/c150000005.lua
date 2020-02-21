--バトル・チェンジ
--Battle Change
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.con)
	e1:SetOperation(s.op)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.GetAttacker():IsContains(tp) and Duel.GetAttacker():GetFlagEffect(id)==0
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local ats=eg:GetFirst():GetAttackableTarget()
	local at=Duel.GetAttackTarget()
	if #ats==0 or (at and #ats==1) then return end
	if Duel.SelectEffectYesNo(tp,e:GetHandler()) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACKTARGET)
		local g=ats:Select(tp,1,1,at)
		Duel.Hint(HINT_CARD,0,id)
		Duel.HintSelection(g)
		Duel.ChangeAttackTarget(g:GetFirst())
		Duel.GetAttacker():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)  
	end
end
