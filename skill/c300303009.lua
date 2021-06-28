--Magician's Act
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddPreDrawSkillProcedure(c,1,false,s.flipcon,s.flipop)
	aux.AddSkillProcedure(c,1,false,s.flipcon2,s.flipop2)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
	and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,CARD_DARK_MAGICIAN)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	--ask if you want to activate the skill or not
	if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--select option
	local opt=0
	local g1=Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_DECK,0,1,nil,CARD_DARK_MAGICIAN)
	local g2=Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_HAND,0,1,nil,CARD_DARK_MAGICIAN)
	if g1 and g2 then
		opt=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	elseif g1 then
		opt=Duel.SelectOption(tp,aux.Stringid(id,1))
	elseif g2 then
		opt=Duel.SelectOption(tp,aux.Stringid(id,2))+1
	else return end
	
	if opt==0 then
	--Add 1 "Dark Magician" from your Deck to your hand, then shuffle 1 card from your hand into the Deck.
		local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_DECK,0,nil,CARD_DARK_MAGICIAN)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		local tdg=Duel.GetFieldGroup(tp,LOCATION_HAND,0):Select(tp,1,1,nil)
		Duel.SendtoDeck(tdg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	else
	--Shuffle 1 "Dark Magician" from your hand into the Deck, then draw 1 card.
		local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_HAND,0,nil,CARD_DARK_MAGICIAN)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sg=g:Select(tp,1,1,nil)
		Duel.ConfirmCards(1-tp,sg)
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		Duel.ShuffleDeck(tp)
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
--tribute 1 DM to draw 2
function s.flipconfilter(c)
	return c:IsFaceup() and c:IsOriginalCode(CARD_DARK_MAGICIAN)
end
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--opd check
	if Duel.GetFlagEffect(ep,id+1)>0 then return end
	--condition
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(s.flipconfilter,tp,LOCATION_ONFIELD,0,1,nil)
	and Duel.IsPlayerCanDraw(tp,2)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--opd register
	Duel.RegisterFlagEffect(ep,id+1,0,0,0)
	local c=e:GetHandler()
	local g=Duel.SelectReleaseGroupCost(tp,s.flipconfilter,1,1,false,aux.ReleaseCheckMMZ,nil,ft,tp)
	Duel.DiscardHand(tp,aux.TRUE,2,2,REASON_COST+REASON_DISCARD)
	Duel.Release(g,REASON_COST)
	Duel.Draw(tp,2,REASON_EFFECT)
end