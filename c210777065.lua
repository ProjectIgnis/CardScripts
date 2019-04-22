--Great Swarm Re-Population
--designed by Nitrogames#8002, scripted by Naim
function c210777065.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,210777065+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c210777065.target)
	e1:SetOperation(c210777065.activate)
	c:RegisterEffect(e1)	
end
function c210777065.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xf11) and c:IsAbleToDeck()
end
function c210777065.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210777065.filter,tp,LOCATION_GRAVE,0,1,nil) end
	local g=Duel.GetMatchingGroup(c210777065.filter,tp,LOCATION_GRAVE,0,1,nil)
	if g:GetCount()>0 then
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
		if  g:GetCount()>4 then
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
		end
	end
end
function c210777065.activate(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.SelectMatchingCard(tp,c210777065.filter,tp,LOCATION_GRAVE,0,1,5,nil)
	if p:GetCount()>0 then
		Duel.SendtoDeck(p,nil,2,REASON_EFFECT)
		local g=Duel.GetOperatedGroup()
		if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
		local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
		if ct==5 then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end


