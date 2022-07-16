--アゲアゲイン
--Excitagain
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local b=Duel.GetAttackTarget()
	return a and b and a:IsControler(1-tp) and b:IsControler(tp) and b:IsFaceup() and b:IsRace(RACE_AQUA)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	if not a then return end
	local value=a:GetAttack()
	if value>0 then
		Duel.Recover(tp,value,REASON_EFFECT)
	end
end
