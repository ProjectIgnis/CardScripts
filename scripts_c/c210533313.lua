--Sayaka's Healing
function c210533313.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c210533313.condition)
	e1:SetTarget(c210533313.target)
	e1:SetOperation(c210533313.operation)
	c:RegisterEffect(e1)
end
c210533313.listed_names={210533303}
function c210533313.conf(c)
	return c:IsFaceup() and c:IsCode(210533303)
end
function c210533313.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c210533313.conf,tp,LOCATION_ONFIELD,0,1,nil)
end
function c210533313.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xf72) and c:IsType(TYPE_PENDULUM) and c:IsCanAddCounter(0x1,1)
end
function c210533313.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210533313.filter,tp,LOCATION_MZONE+LOCATION_PZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,tp,0x1)
end
function c210533313.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(c210533313.filter,tp,LOCATION_MZONE+LOCATION_PZONE,0,nil)
	for tc in aux.Next(g) do
		tc:AddCounter(0x1,1)
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.AND(aux.TargetBoolFunction(Card.IsSetCard,0xf72),aux.TargetBoolFunction(Card.IsType,TYPE_PENDULUM)))
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end