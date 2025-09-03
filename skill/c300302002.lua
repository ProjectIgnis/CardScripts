--Ritual Ceremony
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--Condition check
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(s.ritualrevealfilter,tp,LOCATION_HAND,0,1,nil,tp) and not Duel.HasFlagEffect(tp,id)
end
function s.ritualrevealfilter(c,tp)
	return c:IsRitualMonster() and not c:IsPublic() and Duel.IsExistingMatchingCard(s.ritspellthfilter,tp,LOCATION_DECK,0,1,nil,c)
end
function s.ritspellthfilter(c,tc)
	return c:IsRitualSpell() and tc:ListsCode(c:GetCode()) and c:IsAbleToHand()
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--OPD register
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	--Reveal 1 Ritual Monster in your hand
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.ritualrevealfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	Duel.ConfirmCards(1-tp,g)
	local tc=g:GetFirst()
	--Add 1 Ritual Spell listed on that Ritual Monster
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=Duel.SelectMatchingCard(tp,s.ritspellthfilter,tp,LOCATION_DECK,0,1,1,nil,tc)
	if #sg>0 and Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,sg)
		Duel.ShuffleDeck(tp)
		--Place 1 card from your hand on the bottom of your Deck
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local rg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
		if #rg>0 then
			Duel.BreakEffect()
			Duel.SendtoDeck(rg,tp,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end
