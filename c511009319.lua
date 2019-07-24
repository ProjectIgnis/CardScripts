--Raidraptor - Evasive
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCost(s.cost)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttackTarget()
	return tc and tc:IsControler(tp) and tc:IsFaceup() and tc:IsSetCard(0xba) and tc:IsType(TYPE_XYZ)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xba) and c:IsType(TYPE_XYZ) and c:GetOverlayCount()~=0
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetAttackTarget()
	if chk==0 then return tc:GetOverlayGroup():IsExists(Card.IsAbleToHandAsCost,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=tc:GetOverlayGroup():FilterSelect(tp,Card.IsAbleToHandAsCost,1,1,nil)
	Duel.SendtoHand(g,nil,REASON_COST)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateAttack()
end
