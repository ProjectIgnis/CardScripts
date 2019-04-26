--Madoka's Friends
function c210533311.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,210533311)
	e1:SetCondition(c210533311.condition)
	e1:SetTarget(c210533311.target)
	e1:SetOperation(c210533311.operation)
	c:RegisterEffect(e1)
end
c210533311.listed_names={210533306}
function c210533311.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf73)
end
function c210533311.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c210533311.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function c210533311.filter1(c,tp)
	return not c:IsCode(210533306) and c:IsSetCard(0xf72) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
		and Duel.IsExistingMatchingCard(c210533311.filter2,tp,LOCATION_DECK,0,1,c,c:GetCode())
end
function c210533311.filter2(c,code)
	return not c:IsCode(210533306,code) and c:IsSetCard(0xf72) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
function c210533311.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210533311.filter1,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function c210533311.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g1=Duel.SelectMatchingCard(tp,c210533311.filter1,tp,LOCATION_DECK,0,1,1,nil,tp)
	if #g1>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g2=Duel.SelectMatchingCard(tp,c210533311.filter2,tp,LOCATION_DECK,0,1,1,g1,g1:GetFirst():GetCode())
		g1=g1+g2
		Duel.SendtoHand(g1,tp,REASON_EFFECT)
	end
end