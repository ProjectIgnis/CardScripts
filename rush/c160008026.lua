-- 恵雷の精霊
-- Spirit of Bolt of Inspiration

local s,id=GetID()
function s.initial_effect(c)
	--ATK increase
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--requirement
	if Duel.DiscardDeck(tp,1,REASON_COST)<1 then return end
	--Effect
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,1,nil)
		if #g>0 then
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			local g2=Duel.GetOperatedGroup()
			local ct=g2:FilterCount(Card.IsSpellTrap,nil)
			if #g2>0 and ct>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
				local g3=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,1,nil)
				Duel.SendtoDeck(g3,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			end
		end
	end
end