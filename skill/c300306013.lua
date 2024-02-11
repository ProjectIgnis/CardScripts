--Archfiend's Promotion
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
end
s.listed_series={SET_ARCHFIEND}
s.listed_names={73219648}
function s.vpfilter(c,e,tp)
	local g=c:GetColumnGroup():Filter(Card.IsControler,nil,1-tp)
	return c:IsCode(73219648) and c:IsFaceup() and #g==0 and c:IsReleasable() and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
end
function s.cfilter(c,e,tp)
	return c:IsLevelBelow(8) and c:IsSetCard(SET_ARCHFIEND) and c:IsCode(8581705,9603356,35798491,72192100,52248570) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(s.vpfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Tribute 1 "Vilepawn Archfiend" to Special Summon 1 "Archfiend" with "Queen", "Rook", "Bishop" or "Knight" in its name
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local tc=Duel.SelectMatchingCard(tp,s.vpfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp):GetFirst()
	if Duel.Release(tc,REASON_COST)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
		if sc then
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end