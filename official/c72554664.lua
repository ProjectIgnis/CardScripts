--烙印の光
--Light of the Branded
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Return a Fusion monster to the Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E|TIMING_MAIN_END)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_ALBAZ}
function s.texfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsAbleToExtra()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE|LOCATION_GRAVE) and s.texfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.texfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,LOCATION_MZONE|LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.texfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,LOCATION_MZONE|LOCATION_GRAVE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,PLAYER_ALL,LOCATION_GRAVE)
end
function s.albazfilter(c,e,tp)
	return c:IsCode(CARD_ALBAZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_EXTRA) then
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
		if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 or Duel.GetLocationCount(1-tp,LOCATION_MZONE)==0 then return end
		local g1=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.albazfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
		local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,0,LOCATION_GRAVE,nil,e,tp)
		if #g1>0 and #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc1=g1:Select(tp,1,1,nil):GetFirst()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc2=g2:Select(tp,1,1,nil):GetFirst()
			if sc1 and sc2 then
				Duel.BreakEffect()
				Duel.SpecialSummonStep(sc1,0,tp,tp,false,false,POS_FACEUP)
				Duel.SpecialSummonStep(sc2,0,tp,1-tp,false,false,POS_FACEUP)
			end
			Duel.SpecialSummonComplete()
		end
	end
end