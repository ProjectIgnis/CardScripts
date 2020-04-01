--聖なる守り手
--Mysterious Guard
local s,id=GetID()
function s.initial_effect(c)
	--todeck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter1(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function s.filter2(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g1=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g1==0 then return end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,1,0,0)
	if Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsRace,RACE_WARRIOR),tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingTarget(s.filter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,g1:GetFirst())
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local g2=Duel.SelectTarget(tp,s.filter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,g1:GetFirst())
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g2,1,0,0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ex,g1=Duel.GetOperationInfo(0,CATEGORY_TODECK)
	local ex,g2=Duel.GetOperationInfo(0,CATEGORY_TOHAND)
	local tc1=g1:GetFirst()
	if tc1 and tc1:IsRelateToEffect(e) then
		Duel.SendtoDeck(g1,nil,0,REASON_EFFECT)
	end
	if g2 and g2:GetFirst():IsRelateToEffect(e) then
		Duel.SendtoHand(g2,nil,REASON_EFFECT)
	end
end
