-- 海星の騎兵
-- Sea Star Trooper

--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Shuffle 1 monsters from opponent's GY to deck
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_UMI,CARD_BIG_OCEAN}
	--Check for a monster that can be returned to deck
function s.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
end
	--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_GRAVE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
	-- shuffle 1 monsters from opponent's GY to deck
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	if Duel.DiscardDeck(tp,1,REASON_COST)<1 then return end
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,0,LOCATION_GRAVE,1,1,nil)
	Duel.HintSelection(g)
	if #g>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil) and Duel.IsPlayerCanDiscardDeck(tp,2) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.DiscardDeck(tp,2,REASON_COST)
		end
	end
	
end
function s.cfilter(c)
	return (c:IsCode(CARD_UMI) or c:IsCode(CARD_BIG_OCEAN)) and c:IsFaceup()
end