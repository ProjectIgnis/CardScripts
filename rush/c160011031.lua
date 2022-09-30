--フィーラン・ドワーフ
--Fillan Dwarf
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Send the top 2 cards from the Deck to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_TODECK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_SUMMON_TURN)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,2,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,tp,0)
end
function s.tdfilter(c)
	return c:IsAbleToDeck() and c:IsSpellTrap()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.DiscardDeck(tp,2,REASON_EFFECT)==0 then return end
	if Duel.IsExistingMatchingCard(s.tdfilter,tp,0,LOCATION_GRAVE,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local tg=Duel.SelectMatchingCard(tp,s.tdfilter,tp,0,LOCATION_GRAVE,1,1,nil)
		Duel.SendtoDeck(tg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
