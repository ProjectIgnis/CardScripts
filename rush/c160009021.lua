--ことのはの妖精
--Poet Fairy

--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Shuffle 3 monsters from opponent's GY to deck
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_SUMMON_TURN) and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
	--Check for card in hand to send to GY
function s.tdcfilter(c)
	return c:IsMonster() and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdcfilter,tp,LOCATION_GRAVE,0,3,nil) end
end
	--Check for a monster that can be returned to deck
function s.tdfilter(c)
	return c:IsMonster() and c:IsAbleToDeck()
end
	--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,0,LOCATION_GRAVE,3,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,1-tp,LOCATION_GRAVE)
end
	-- shuffle 3 monsters from your Graveyard into the Deck. to shuffle 3 monsters from opponent's GY to deck
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.tdcfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	if #g==0 then return end
	Duel.HintSelection(g,true)
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)>0 then
		--Effect
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local dg1=Duel.SelectMatchingCard(tp,s.tdfilter,tp,0,LOCATION_GRAVE,3,3,nil)
		if #dg1==0 then return end
		Duel.HintSelection(dg1,true)
		if Duel.SendtoDeck(dg1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,2,nil)
			and Duel.IsExistingMatchingCard(s.tdfilter,tp,0,LOCATION_GRAVE,3,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local dg2=Duel.SelectMatchingCard(tp,s.tdfilter,tp,0,LOCATION_GRAVE,3,3,nil)
			if #dg2==0 then return end
			Duel.HintSelection(dg2,true)
			Duel.BreakEffect()
			Duel.SendtoDeck(dg2,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and not c:IsLevel(1)
end