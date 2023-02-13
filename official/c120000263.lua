--SR三つ目のダイス
function c120000263.initial_effect(c)
	--disable attack
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(120000263,0))
	e1:SetCategory(CATEGORY_NEGATEATTACK)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_ATTACK)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c120000263.condition)
	e1:SetTarget(c120000263.target)
	e1:SetCost(aux.bfgcost)
	e1:SetOperation(c120000263.operation)
	c:RegisterEffect(e1)
end
function c120000263.condition(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	return at and at:IsControler(1-tp)
end
function s.c120000263(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local a=Duel.GetAttacker()
	Duel.SetOperationInfo(0,CATEGORY_NEGATEATTACK,a,1,0,0)
end
function c120000263.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetAttacker() then 
	Duel.NegateAttack()
	end
end
