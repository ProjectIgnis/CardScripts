--三幻魔の天壊
--Shimmering Shatterer of the Sacred Beasts
--scripted by pyrQ
local s,id=GetID()
local CARD_ILLUSION_GATE=33017964
function s.initial_effect(c)
	--Activate 1 of these effects;
	--● When your opponent activates a card or effect in response to your "Sacred Beast" monster's effect activation: Negate that opponent's effect
	--● Reveal 1 Level 10 "Sacred Beast" monster in your hand; discard 1 card, and if you do, add 1 "Illusion Gate" from your Deck to your hand
	--● Shuffle 3 "Sacred Beast" Traps from your GY and/or banishment into the Deck, then target 1 card your opponent controls; destroy it
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.effcost)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
end
s.listed_series={SET_SACRED_BEAST}
s.listed_names={CARD_ILLUSION_GATE}
function s.revealfilter(c)
	return c:IsLevel(10) and c:IsSetCard(SET_SACRED_BEAST) and not c:IsPublic()
end
function s.thfilter(c)
	return c:IsCode(CARD_ILLUSION_GATE) and c:IsAbleToHand()
end
function s.tdfilter(c)
	return c:IsSetCard(SET_SACRED_BEAST) and c:IsTrap() and c:IsFaceup() and c:IsAbleToDeckAsCost()
end
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	--● When your opponent activates a card or effect in response to your "Sacred Beast" monster's effect activation: Negate that opponent's effect
	local event_chk,_,event_player,event_value,event_reff=Duel.CheckEvent(EVENT_CHAINING,true)
	local option_1=event_chk and event_player==1-tp and Chain.IsTriggeringPlayer(event_value-1,tp)
		and Chain.IsTriggeringSetcode(event_value-1,SET_SACRED_BEAST)
		and Chain.IsTriggeringType(event_value-1,TYPE_MONSTER)
		and Duel.IsChainDisablable(event_value)
	--● Reveal 1 Level 10 "Sacred Beast" monster in your hand; discard 1 card, and if you do, add 1 "Illusion Gate" from your Deck to your hand
	local option_2=Duel.IsExistingMatchingCard(s.revealfilter,tp,LOCATION_HAND,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil,REASON_EFFECT)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	--● Shuffle 3 "Sacred Beast" Traps from your GY and/or banishment into the Deck, then target 1 card your opponent controls; destroy it
	local option_3=Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,3,nil)
		and Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil)
	if chk==0 then return option_1 or option_2 or option_3 end
	local choice=Duel.SelectEffect(tp,
		{option_1,aux.Stringid(id,1)},
		{option_2,aux.Stringid(id,2)},
		{option_3,aux.Stringid(id,3)})
	e:GetChainData().choice=choice
	if choice==1 then
		--● When your opponent activates a card or effect in response to your "Sacred Beast" monster's effect activation: Negate that opponent's effect
		e:SetCategory(CATEGORY_DISABLE)
		e:SetProperty(0)
		e:GetChainData().event_value=event_value
	elseif choice==2 then
		--● Reveal 1 Level 10 "Sacred Beast" monster in your hand; discard 1 card, and if you do, add 1 "Illusion Gate" from your Deck to your hand
		e:SetCategory(CATEGORY_HANDES+CATEGORY_TOHAND+CATEGORY_SEARCH)
		e:SetProperty(0)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local g=Duel.SelectMatchingCard(tp,s.revealfilter,tp,LOCATION_HAND,0,1,1,nil)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
	elseif choice==3 then
		--● Shuffle 3 "Sacred Beast" Traps from your GY and/or banishment into the Deck, then target 1 card your opponent controls; destroy it
		e:SetCategory(CATEGORY_DESTROY)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,3,3,nil)
		Duel.HintSelection(g)
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
	end
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return e:GetChainData().choice==3 and chkc:IsControler(1-tp) and chkc:IsOnField() end
	if chk==0 then return true end
	local choice=e:GetChainData().choice
	if choice==1 then
		--● When your opponent activates a card or effect in response to your "Sacred Beast" monster's effect activation: Negate that opponent's effect
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,tp,0)
	elseif choice==2 then
		--● Reveal 1 Level 10 "Sacred Beast" monster in your hand; discard 1 card, and if you do, add 1 "Illusion Gate" from your Deck to your hand
		Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif choice==3 then
		--● Shuffle 3 "Sacred Beast" Traps from your GY and/or banishment into the Deck, then target 1 card your opponent controls; destroy it
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local choice=e:GetChainData().choice
	if choice==1 then
		--● When your opponent activates a card or effect in response to your "Sacred Beast" monster's effect activation: Negate that opponent's effect
		Duel.NegateEffect(e:GetChainData().event_value)
	elseif choice==2 then
		--● Reveal 1 Level 10 "Sacred Beast" monster in your hand; discard 1 card, and if you do, add 1 "Illusion Gate" from your Deck to your hand
		if Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_EFFECT|REASON_DISCARD,nil,REASON_EFFECT)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
			if #g>0 then
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
			end
		end
	elseif choice==3 then
		--● Shuffle 3 "Sacred Beast" Traps from your GY and/or banishment into the Deck, then target 1 card your opponent controls; destroy it
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end