--The Right Hero for the Job
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
s.listed_series={SET_ELEMENTAL_HERO}
function s.cfilter(c,e,tp)
	return c:IsSetCard(SET_ELEMENTAL_HERO) and c:IsMonster() and c:IsAbleToDeck()
		and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
function s.cfilter2(c,e,tp,code)
	return c:IsSetCard(SET_ELEMENTAL_HERO) and c:IsMonster() and c:IsLevelBelow(4) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and Duel.GetFlagEffect(ep,id)==0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--OPD Register
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	--Shuffle 1 E-Hero from MMZ to Deck to Special Summon 1 Level 4 or lower E-Hero with different name
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp):GetFirst()
	local code=tc:GetCode()
	if Duel.SendtoDeck(tc,tp,0,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
		if tc:IsLocation(LOCATION_DECK) then Duel.ShuffleDeck(tp) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,code):GetFirst()
		if sc then
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end