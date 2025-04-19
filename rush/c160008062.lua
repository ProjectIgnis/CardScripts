--最強闘志
-- Ultimate Fighting Spirit

local s,id=GetID()
function s.initial_effect(c)
	--negate attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local tc=Duel.GetAttackTarget()
	return a and a:IsControler(1-tp) and a:IsLevelBelow(9) and tc and tc:IsDefensePos() and tc:IsControler(tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg=Duel.GetAttackTarget()
	if chk==0 then return tg:IsControler(tp) and tg:IsOnField() end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.NegateAttack()
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		if Duel.ChangePosition(g,0,0,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)>0 then
			if g:GetFirst():IsType(TYPE_NORMAL) then
				--Increase ATK
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(1000)
				e1:SetReset(RESETS_STANDARD_PHASE_END)
				g:GetFirst():RegisterEffect(e1)
			end
		end
	end
end
function s.filter(c)
	return c:IsDefensePos() and c:IsCanChangePositionRush()
end