--call of critas
function c270770100.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,270770100)
	e1:SetCost(c270770100.cost)
	e1:SetTarget(c270770100.target)
	e1:SetOperation(c270770100.activate)
	c:RegisterEffect(e1)
end
function c270770100.filter(c,code)
	return c:IsCode(code) and c:IsAbleToHand() and (code==11082056 or c:IsType(TYPE_TRAP))
end
function c270770100.exfilter(c,tp)
	return c:IsCode(58293343,84687358,100241003,22804644) and c.material_trap
		and Duel.IsExistingMatchingCard(c270770100.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,c.material_trap)
end
function c270770100.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) 
		and Duel.IsExistingMatchingCard(c270770100.exfilter,tp,LOCATION_EXTRA,0,1,nil,tp) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,c270770100.exfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
	Duel.ConfirmCards(1-tp,g)
	e:SetLabel(g:GetFirst().material_trap)
end
function c270770100.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c270770100.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,11082056) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function c270770100.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c270770100.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e:GetLabel())
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
		local cg=Duel.SelectMatchingCard(tp,c270770100.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,11082056)
		Duel.SendtoHand(cg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,cg)
	end
end