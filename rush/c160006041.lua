--JAM:P Set!
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
end
function s.costfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_PSYCHIC) and c:GetLevel()==2 and c:IsAbleToDeckAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
end

function s.rtdfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsLevelBelow(8) and c:IsAbleToDeck() and not c:IsMaximumModeSide()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rtdfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	--requirement
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	local tdg=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
	
	--effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g2=Duel.SelectMatchingCard(tp,s.rtdfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	g2:AddMaximumCheck()
	if #g2>0 then
		Duel.HintSelection(g2)
		Duel.SendtoDeck(g2,nil,0,REASON_EFFECT)
		if tdg:GetFirst():IsCode(CARD_CAN_D) and Duel.IsExistingMatchingCard(s.tdfilter,tp,0,LOCATION_GRAVE,1,nil) then
			local tdg2=Duel.SelectMatchingCard(tp,s.tdfilter,tp,0,LOCATION_GRAVE,1,1,nil)
			Duel.SendtoDeck(tdg2,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
function s.tdfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end