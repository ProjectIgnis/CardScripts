-- ロイヤル・ストレート
-- Royal Straight
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Send "Jack's Knight", "Queen's Knight", and "King's Knight" to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_JACK_KNIGHT,CARD_QUEEN_KNIGHT,CARD_KING_KNIGHT}
function s.tgfilter(c)
	return c:IsCode(CARD_JACK_KNIGHT,CARD_QUEEN_KNIGHT,CARD_KING_KNIGHT)
		and (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsAbleToGrave()
end
s.listfilter=aux.OR(aux.IsCodeListed,aux.IsMaterialListCode)
function s.spfilter(c,e,tp)
	if not (s.listfilter(c,CARD_JACK_KNIGHT) and s.listfilter(c,CARD_QUEEN_KNIGHT) and s.listfilter(c,CARD_KING_KNIGHT)) then return end
	local code_chk=c:IsCode(100290001)
	return c:IsCanBeSpecialSummoned(e,0,tp,code_chk,code_chk)
end
function s.spchkfilter(c,sg,tp)
	return (c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,sg,c) or Duel.GetMZoneCount(tp,sg))>0
end
function s.tgrescon(summg)
	return function(sg,e,tp)
		local res,stop=aux.dncheck(sg)
		return res and summg:IsExists(s.spchkfilter,1,nil,sg,tp),stop
	end
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local summg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE,0,nil,e,tp)
		if #summg<1 then return false end
		local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,nil)
		return #g>2 and aux.SelectUnselectGroup(g,e,tp,3,3,s.tgrescon(summg),0)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,3,tp,LOCATION_MZONE+LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local summg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE,0,nil,e,tp)
	if #summg<1 then return end
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,nil)
	if #g<3 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	g=aux.SelectUnselectGroup(g,e,tp,3,3,s.tgrescon(summg),1,tp,HINTMSG_TOGRAVE)
	if #g==3 and Duel.SendtoGrave(g,REASON_EFFECT)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=summg:FilterSelect(tp,s.spchkfilter,1,1,nil,nil,tp):GetFirst()
		if sc then
			local code_chk=sc:IsCode(100290001)
			Duel.BreakEffect()
			Duel.SpecialSummon(sc,0,tp,tp,code_chk,code_chk,POS_FACEUP)
			if code_chk then sc:CompleteProcedure() end
		end
	end
end