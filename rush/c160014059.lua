--ケミカライズ・デスパイズ
--Chemicalize Despise
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Negate attack and destroy the attacking monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DESTROY)
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
	return a and a:IsControler(1-tp) and tc and tc:IsFaceup() and tc:IsRace(RACE_PYRO) and tc:IsControler(tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg=Duel.GetAttackTarget()
	if chk==0 then return tg:IsControler(tp) and tg:IsOnField() end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,tg,1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local a=Duel.GetAttacker()
	local tc=Duel.GetAttackTarget()
	Duel.NegateAttack()
	if tc:GetLevel()>a:GetLevel() and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		local tg=Group.CreateGroup()
		tg:AddCard(a)
		tg=tg:AddMaximumCheck()
		Duel.Destroy(tg,REASON_EFFECT)
	end
end