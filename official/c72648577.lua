--DDDの人事権
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={0xaf}
function s.filter(c)
	return c:IsSetCard(0xaf) and (c:IsType(TYPE_MONSTER) or c:IsLocation(LOCATION_PZONE)) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsAbleToDeck()
end
function s.thfilter(c)
	return c:IsSetCard(0xaf) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE+LOCATION_PZONE+LOCATION_GRAVE+LOCATION_HAND,0,3,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_MZONE+LOCATION_PZONE+LOCATION_GRAVE+LOCATION_HAND)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter),tp,LOCATION_MZONE+LOCATION_PZONE+LOCATION_GRAVE+LOCATION_HAND,0,nil)
	if #g<3 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=g:Select(tp,3,3,nil)
	local cg=sg:Filter(Card.IsLocation,nil,LOCATION_HAND)
	Duel.ConfirmCards(1-tp,cg)
	Duel.SendtoDeck(sg,nil,0,REASON_EFFECT)
	local dg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #dg>1 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tg=dg:Select(tp,2,2,nil)
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tg)
	else
		if sg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
			Duel.ShuffleDeck(tp)
		end
	end
end
