--Call of Hermos
--designed by Xeno Disturbia#5235
--scripted by Naim, credits to Larry126 for the fixes
function c210777029.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,210777029)
	e1:SetCost(c210777029.cost)
	e1:SetTarget(c210777029.target)
	e1:SetOperation(c210777029.activate)
	e1:SetLabel(0)
	c:RegisterEffect(e1)
end
function c210777029.hermfilter(c) --this is hermos
	return c:IsCode(46232525) and c:IsAbleToHand()
end
function c210777029.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function c210777029.tohandfilter(c,tc,e,tp) --the thing that should be added (this is a simplification)
	return c:GetOriginalLevel()==tc:GetOriginalLevel()
		and c:GetOriginalRace()==tc:GetOriginalRace()
		and c:GetOriginalAttribute()==tc:GetOriginalAttribute()
		and c:GetBaseAttack()==tc:GetBaseAttack()
		and c:GetBaseDefense()==tc:GetBaseDefense()
end
function c210777029.exfilter(c,e,tp) --the thing in the ED that can be revealed
	return c:IsCode(19747827,83743222,46354113,10960419) and c:IsLocation(LOCATION_EXTRA)--cards that can only be summoned with Hermos
		and Duel.IsExistingMatchingCard(c210777029.tohandfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,c,e,tp)
end
function c210777029.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return e:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsExistingMatchingCard(c210777029.exfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) 
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler())
		and Duel.IsExistingMatchingCard(c210777029.hermfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	end
	e:SetLabel(0)
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK+LOCATION_GRAVE)
	local g=Duel.SelectMatchingCard(tp,c210777029.exfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	Duel.ConfirmCards(1-tp,g)
	e:SetLabelObject(g:GetFirst())
	Duel.SetTargetCard(g)
end
function c210777029.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	tc=e:GetLabelObject()
	local cg=Duel.SelectMatchingCard(tp,c210777029.tohandfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tc,e,tp)
	if cg:GetCount()>0 and Duel.SendtoHand(cg,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,cg)
		local g=Duel.SelectMatchingCard(tp,c210777029.hermfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
