--Element Counter
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.GetAttackTarget()
	return d and d:IsSetCard(0x3008)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg=Duel.GetAttacker()
	if chk==0 then return tg:IsOnField() end
	Duel.SetTargetCard(tg)
	local dam=Duel.GetMatchingGroupCount(Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,0x3008)*500
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local dam=Duel.GetMatchingGroupCount(Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,0x3008)*500
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:CanAttack() then
		if Duel.NegateAttack() then
			Duel.Damage(1-tp,dam,REASON_EFFECT)
		end
	end
end
