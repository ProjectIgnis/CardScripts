--Class System
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if ep==tp or not re:IsActiveType(TYPE_MONSTER) or not Duel.IsChainDisablable(ev) then return false end
	return a and d and a:IsControler(1-tp) and re:GetHandler()==a and d:IsControler(tp) and a:GetLevel()>0 and d:GetLevel()>0 
		and a:GetLevel()<=d:GetLevel() 
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	Duel.NegateAttack(a)
	Duel.NegateEffect(ev)
end
