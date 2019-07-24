--Escape Lure
local s,id=GetID()
function s.initial_effect(c)
	--change target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.atkcon)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return tp~=Duel.GetTurnPlayer()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local at=Duel.GetAttackTarget()
	if chk==0 then
		if at then
			return Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,0,1,at) 
		else
			return Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,0,1,nil) 
		end
	end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	if Duel.GetAttackTarget() then
		g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_MZONE,0,1,1,Duel.GetAttackTarget())
	else
		g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_MZONE,0,1,1,nil)
	end
	if #g>0 then
		Duel.ChangeAttackTarget(g:GetFirst())
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
		e1:SetOperation(s.rdop)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.rdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(tp,ev/2)
	Duel.ChangeBattleDamage(1-tp,ev/2)
end
