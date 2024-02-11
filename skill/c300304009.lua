--The Right Hero for the Job
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
s.listed_series={SET_ELEMENTAL_HERO}
function s.tdfilter(c,e,tp)
	return c:IsSetCard(SET_ELEMENTAL_HERO) and c:IsAbleToDeck() and not c:IsType(TYPE_EXTRA) and Duel.GetMZoneCount(tp,c)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
function s.spfilter(c,e,tp,code)
	return c:IsSetCard(SET_ELEMENTAL_HERO) and c:IsLevelBelow(4) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and not Duel.HasFlagEffect(ep,id) and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--OPD Register
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	--Shuffle 1 "Elemental HERO" monster you control into your Main Deck, then Special Summon 1 Level 4 or lower "Elemental HERO" monster from your Deck with a different name
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tc=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp):GetFirst()
	Duel.HintSelection(tc,true)
	if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_DECK) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetCode())
		if #g>0 then
			Duel.BreakEffect()
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
