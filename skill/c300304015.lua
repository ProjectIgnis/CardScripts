--Cyberdark Style
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
end
s.listed_series={SET_CYBERDARK}
function s.filter(c)
	return c:IsSetCard(SET_CYBERDARK) and c:IsMonster() and c:IsAbleToHand()
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.GetFlagEffect(ep,id)==0 and Duel.GetLP(tp)<=3000
	local b2=Duel.GetFlagEffect(ep,id+100)==0 and Duel.GetLP(tp)<=2000
	local b3=Duel.GetFlagEffect(ep,id+200)==0 and Duel.GetLP(tp)<=1000
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,3,nil) and (b1 or b2 or b3)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	--TPD Register
	local b1=Duel.GetFlagEffect(ep,id)==0 and Duel.GetLP(tp)<=3000
	local b2=Duel.GetFlagEffect(ep,id+100)==0 and Duel.GetLP(tp)<=2000
	local b3=Duel.GetFlagEffect(ep,id+200)==0 and Duel.GetLP(tp)<=1000
	if b1 and not (b2 or b3) then
		Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
		Duel.Hint(HINT_CARD,tp,id)
		--Choose 3 "Cyberdark" monsters, then add 1 and shuffle 1 card from hand to Deck (LP 3000 or less)
		Duel.RegisterFlagEffect(ep,id,0,0,0)
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,3,3,nil)
		Duel.ConfirmCards(1-tp,sg)
		Duel.ShuffleDeck(tp)
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)
		local tg=sg:Select(1-tp,1,1,nil)
		if Duel.SendtoHand(tg,tp,REASON_EFFECT)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local dg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
			Duel.SendtoDeck(dg,tp,2,REASON_EFFECT)
			Duel.Hint(HINT_SKILL_FLIP,tp,id|(2<<32))
		end
	elseif (b2 or b3) and not b1 then
		Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
		Duel.Hint(HINT_CARD,tp,id)
		--Choose 3 "Cyberdark" monsters, then add 1 and shuffle 1 card from hand to Deck (LP 2000 or less)
		Duel.RegisterFlagEffect(ep,id+100,0,0,0)
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,3,3,nil)
		Duel.ConfirmCards(1-tp,sg)
		Duel.ShuffleDeck(tp)
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)
		local tg=sg:Select(1-tp,1,1,nil)
		if Duel.SendtoHand(tg,tp,REASON_EFFECT)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local dg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
			Duel.SendtoDeck(dg,tp,2,REASON_EFFECT)
			Duel.Hint(HINT_SKILL_FLIP,tp,id|(2<<32))
		end
	elseif b3 and not (b1 or b2) then
		Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
		Duel.Hint(HINT_CARD,tp,id)
		--Choose 3 "Cyberdark" monsters, then add 1 and shuffle 1 card from hand to Deck (LP 1000 or less)
		Duel.RegisterFlagEffect(ep,id+200,0,0,0)
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,3,3,nil)
		Duel.ConfirmCards(1-tp,sg)
		Duel.ShuffleDeck(tp)
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)
		local tg=sg:Select(1-tp,1,1,nil)
		if Duel.SendtoHand(tg,tp,REASON_EFFECT)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local dg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
			Duel.SendtoDeck(dg,tp,2,REASON_EFFECT)
			Duel.Hint(HINT_SKILL_FLIP,tp,id|(2<<32))
		end
	end
end