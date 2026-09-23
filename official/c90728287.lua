--無垢なる芸術－「幻創の賢者」
--Ars Magna - "Philosophirum"
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Target up to 3 "Ars Magna" monsters in your field and/or GY; banish them, then you can negate the effects of up to the same number of face-up cards on the field until the end of this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.bantg)
	e1:SetOperation(s.banop)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--You can banish this card from your GY; return 1 "Power Patron" Link Monster from your GY into the Extra Deck, then you can Special Summon it
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.retsptg)
	e2:SetOperation(s.retspop)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e2)
end
s.listed_series={SET_ARS_MAGNA,SET_POWER_PATRON}
function s.banfilter(c)
	return c:IsSetCard(SET_ARS_MAGNA) and c:IsMonster() and c:IsAbleToRemove() and c:IsFaceup()
end
function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE|LOCATION_GRAVE) and s.banfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.banfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.banfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DISABLE,nil,#g,PLAYER_EITHER,LOCATION_ONFIELD)
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 and Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)>0 then
		local max_negate_count=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_REMOVED)
		if max_negate_count==0 then return end
		local c=e:GetHandler()
		local exc=c:IsRelateToEffect(e) and c or nil
		local g=Duel.GetMatchingGroup(Card.IsNegatable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,exc)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
			local dg=g:Select(tp,1,max_negate_count,nil)
			if #dg==0 then return end
			Duel.HintSelection(dg)
			Duel.BreakEffect()
			for dc in dg:Iter() do
				--Negate the effects of up to the same number of face-up cards on the field until the end of this turn
				dc:NegateEffects(c,RESET_PHASE|PHASE_END,true)
			end
		end
	end
end
function s.retfilter(c)
	return c:IsSetCard(SET_POWER_PATRON) and c:IsLinkMonster() and c:IsAbleToExtra()
end
function s.retsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.retfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.retspop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sc=Duel.SelectMatchingCard(tp,s.retfilter,tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if not sc then return end
	Duel.HintSelection(sc)
	if Duel.SendtoDeck(sc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_EXTRA)
		and Duel.GetLocationCountFromEx(tp,tp,nil,sc)>0
		and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.BreakEffect()
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
	end
end