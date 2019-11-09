--Attack Guidance Armor
local s,id=GetID()
function s.initial_effect(c)
	--change target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return tp~=Duel.GetTurnPlayer()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDefensePos,tp,LOCATION_MZONE,0,1,Duel.GetAttackTarget()) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local g=Duel.SelectMatchingCard(tp,Card.IsDefensePos,tp,LOCATION_MZONE,0,1,1,Duel.GetAttackTarget())
	local tc=g:GetFirst()
	if tc then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(600)
		tc:RegisterEffect(e1)
		if a:CanAttack() and not a:IsImmuneToEffect(e) and not tc:IsImmuneToEffect(e) then 
			Duel.CalculateDamage(a,tc)
			Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE,1)
		end
	end
end
