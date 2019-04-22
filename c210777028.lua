--Call of Timaeus
--designed by Xeno Disturbia#5235, scripted by Naim
function c210777028.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,210777028)
	e1:SetCost(c210777028.cost)
	e1:SetTarget(c210777028.target)
	e1:SetOperation(c210777028.activate)
	c:RegisterEffect(e1)
end
c210777028.listed_names={46986414,38033121,1784686}
function c210777028.timfilter(c)
	return c:IsCode(1784686) and c:IsAbleToHand()
end
function c210777028.mfilter(c)
	return c:IsCode(46986414,38033121) and c:IsAbleToHand()
end
function c210777028.exfilter(c,tp)
	return c:IsCode(75380687,43892408) --cards that can only be summoned with Timaeus
		and Duel.IsExistingMatchingCard(c210777028.mfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingMatchingCard(c210777028.timfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
end
function c210777028.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) 
		and Duel.IsExistingMatchingCard(c210777028.exfilter,tp,LOCATION_EXTRA,0,1,nil,tp) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,c210777028.exfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
	Duel.ConfirmCards(1-tp,g)
	e:SetLabel(g:GetFirst())
end
function c210777028.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210777028.timfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function c210777028.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c210777028.timfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
		local cg=Duel.SelectMatchingCard(tp,c210777028.mfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
		Duel.SendtoHand(cg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,cg)
	end
end