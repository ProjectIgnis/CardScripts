--魔法の筒
--Magic Cylinder (Rush)
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Negate opponent monster's attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local at=Duel.GetAttacker()
	if chk==0 then return at:IsControler(1-tp) end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(at:GetAttack())
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,at:GetAttack())
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.NegateAttack()
	Duel.Damage(p,d,REASON_EFFECT)
end
