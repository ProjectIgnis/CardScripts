--千年の十字
--Millennium Ankh
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_FORBIDDEN_ONE,SET_EXODIA,SET_MILLENNIUM}
s.listed_names={83257450} --"The Phantom Exodia Incarnate"
function s.spfilter(c,e,tp)
	return c:IsCode(83257450) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.showfilter(c)
	return c:IsSetCard(SET_FORBIDDEN_ONE) and c:IsOriginalType(TYPE_MONSTER)
		and (c:IsLocation(LOCATION_HAND|LOCATION_DECK) or c:IsFaceup())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
		and Duel.IsExistingMatchingCard(s.showfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_ONFIELD,0,5,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_ONFIELD)
end
function s.tdfilter(c)
	if (c:IsSetCard(SET_EXODIA) and c:GetOriginalLevel()>=10) or c:IsSetCard(SET_MILLENNIUM) then return false end
	return c:IsOriginalType(TYPE_MONSTER) and c:IsFaceup() and c:IsAbleToDeck()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local rg=Duel.GetMatchingGroup(s.showfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_ONFIELD,0,nil)
	if #rg>5 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		rg=Duel.SelectMatchingCard(tp,s.showfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_ONFIELD,0,5,5,nil)
	end
	if #rg==5 then
		Duel.ConfirmCards(1-tp,rg)
		if rg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then Duel.ShuffleHand(tp) end
		if rg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
		if sc then
			local tdg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_ONFIELD,0,nil)
			Duel.BreakEffect()
			if Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 and #tdg>0 then
				Duel.BreakEffect()
				Duel.SendtoDeck(tdg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			end
		end
	end
	local c=e:GetHandler()
	--Cannot Summon monsters for the rest of this turn (but you can Normal Set)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	Duel.RegisterEffect(e3,tp)
	--Shuffle this card into the Deck instead of sending it to the GY
	if c:IsRelateToEffect(e) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		if c:IsHasEffect(EFFECT_CANNOT_TO_DECK) then return end
		c:CancelToGrave()
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end