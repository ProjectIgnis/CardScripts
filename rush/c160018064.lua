--仕組まれた相打ち
--Intentional Draw
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Return to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttackTarget()
	local ac=Duel.GetAttacker()
	return tc and tc:IsFaceup() and tc:IsControler(tp) and ac:IsControler(1-tp) and tc:IsAttackPos()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg=Duel.GetAttackTarget()
	if chk==0 then return tg:IsControler(tp) and tg:IsOnField() end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local d=Duel.GetAttackTarget()
	local a=Duel.GetAttacker()
	local tg=Group.CreateGroup()
	tg:AddCard(d)
	tg:AddCard(a)
	tg=tg:AddMaximumCheck()
	Duel.SendtoHand(tg,nil,REASON_EFFECT)
end