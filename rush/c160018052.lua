--サイクイップ・ダ・カーポ
--Psyquip da Capo
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Send the top 2 cards of your Deck to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_FUSION,160015051} --Psyquip Fusion
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,2)
end
function s.tdfilter(c)
	return c:IsAbleToDeck() and c:IsCode(CARD_FUSION,160015051)
end
function s.thfilter(c)
	return ((c:IsRace(RACE_PSYCHIC) and c:IsAttribute(ATTRIBUTE_WIND)) or c:IsCode(CARD_FUSION,160015051)) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.DiscardDeck(tp,2,REASON_EFFECT)
	if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local tg=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.HintSelection(tg)
		local opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
		local tdc=0
		if opt==0 then
			tdc=Duel.SendtoDeck(tg,nil,SEQ_DECKTOP,REASON_EFFECT)
		elseif opt==1 then
			tdc=Duel.SendtoDeck(tg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
		if tdc>0 and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
			if #g>0 then
				Duel.BreakEffect()
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
			end
		end
	end
end