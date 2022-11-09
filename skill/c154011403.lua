--Endless Trap Hell
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--skill
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
function s.filter(c)
	return c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return aux.CanActivateSkill(tp) and Duel.GetFlagEffect(ep,id)==0 and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE,0,3,nil) 
	and not (Duel.IsPlayerAffectedByEffect(tp,EFFECT_CANNOT_TO_HAND) or Duel.IsPlayerAffectedByEffect(tp,EFFECT_CANNOT_TO_DECK))
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--opd register
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	--Add 1 Trap to hand then return 1 card from the hand to Deck
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE,0,nil)
	local tc=g:RandomSelect(tp,1):GetFirst()
	if Duel.SendtoHand(tc,tp,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local dg=Duel.SelectingMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1nil)
		if #dg>0 then 
			Duel.SendtoDeck(dg,tp,2,REASON_EFFECT)
		end
	end
end



