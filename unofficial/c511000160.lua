--ハイパーフレッシュ
--Hyper Refresh
local s,id=GetID()
function s.initial_effect(c)
	--Double your LP
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local og=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local cg=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	local atk=og:GetSum(Card.GetAttack)
	return Duel.GetLP(tp)<atk and #cg==0
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
        local og=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local cg=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	local atk=og:GetSum(Card.GetAttack)
        if Duel.GetLP(tp)>=atk or #cg>0 then return false end
	Duel.SetLP(tp,(Duel.GetLP(tp)*2),REASON_EFFECT)
end