--アマゾネスの調教師
--Amazoness Trainer
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={10979723} --"Amazoness Tiger"
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.GetAttacker()
	local bc=ac:GetBattleTarget()
	if not bc then return false end
	if bc:IsControler(tp) or ac:IsControler(1-tp) then return false end
	return ac and ac:IsCode(10979723) and bc and bc:IsRelateToBattle() and ac:CanChainAttack()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ac=Duel.GetAttacker()
	if chk==0 then return ac:CanChainAttack() end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ac=Duel.GetAttacker()
	local bc=ac:GetBattleTarget()	
	if ac and ac:IsRelateToBattle() and ac:IsFaceup() and bc:IsOnField() then
		ac:UpdateAttack(400)
		Duel.ChainAttack(bc)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetCode(EFFECT_PIERCE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_BATTLE|PHASE_DAMAGE_CAL)
		ac:RegisterEffect(e1,true)
	end
end
