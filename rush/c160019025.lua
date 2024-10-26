--舞踊る恵雷の精霊
--Dancing Lightning Bringer Spirit
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Name becomes "Lightning Bringer Spirit" in the Graveyard
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_GRAVE)
	e0:SetValue(160008026)
	c:RegisterEffect(e0)
	--Shuffle 1 card from each player's GY into the Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_SUMMON_TURN) and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=10
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,1,nil) and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g1=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g1==0 then return end
	local g2=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,1,nil)
	if #g2==0 then return end
	g1:Merge(g2)
	Duel.HintSelection(g1)
	if Duel.SendtoDeck(g1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		Duel.ShuffleDeck(tp)
		Duel.ShuffleDeck(1-tp)
		local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_GRAVE)
		if ct<=5 and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end