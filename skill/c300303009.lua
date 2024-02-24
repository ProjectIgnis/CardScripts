--Magician's Act
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddPreDrawSkillProcedure(c,1,false,s.flipcon,s.flipop)
	aux.AddSkillProcedure(c,1,false,s.flipcon2,s.flipop2)
end
s.listed_names={CARD_DARK_MAGICIAN}
function s.thfilter(c)
	return c:IsCode(CARD_DARK_MAGICIAN) and c:IsAbleToHand()
end
function s.tdfilter(c)
	return c:IsCode(CARD_DARK_MAGICIAN) and c:IsAbleToDeck()
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and
		(Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) or
		(Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_HAND,0,1,nil) and Duel.IsPlayerCanDraw(tp,1)))
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	--ask if you want to activate the skill or not
	if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--select option
	local opt=0
	local g1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	local g2=Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_HAND,0,1,nil) and Duel.IsPlayerCanDraw(tp,1)
	local opt=Duel.SelectEffect(tp,
		{g1,aux.Stringid(id,1)},
		{g2,aux.Stringid(id,2)})
	if opt==1 then
		--Add 1 "Dark Magician" from your Deck to your hand, then shuffle 1 card from your hand into the Deck.
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
			Duel.ConfirmCards(1-tp,g)
			Duel.ShuffleHand(tp)
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local dg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
			Duel.SendtoDeck(dg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	elseif opt==2 then
		--Shuffle 1 "Dark Magician" from your hand into the Deck, then draw 1 card.
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local dg=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_HAND,0,1,1,nil)
		Duel.SendtoDeck(dg,nil,SEQ_DECKTOP,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,dg)
		Duel.SendtoDeck(dg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		Duel.ShuffleDeck(tp)
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(ep,id+1)==0 and aux.CanActivateSkill(tp)
		and Duel.CheckReleaseGroupCost(tp,Card.IsOriginalCode,1,false,nil,nil,CARD_DARK_MAGICIAN)
		and Duel.IsPlayerCanDraw(tp,2)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(ep,id+1,0,0,0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectReleaseGroupCost(tp,Card.IsOriginalCode,1,1,false,nil,nil,CARD_DARK_MAGICIAN)
	Duel.Release(g,REASON_COST)
	Duel.Draw(tp,2,REASON_EFFECT)
end