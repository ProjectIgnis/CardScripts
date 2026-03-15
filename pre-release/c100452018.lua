--トリプル・ヴァレル・リボルブ
--Triple Borrel Launch
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects (but you can only use each effect of "Triple Borrel Launch" once per turn);
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
end
s.listed_series={SET_ROKKET}
function s.tdfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToDeck()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil)
	--● Shuffle 1 Dragon monster from your GY into the Deck, then you can Special Summon 1 "Rokket" monster with a different name from your Deck
	local b1=not Duel.HasFlagEffect(tp,id) and #dg>=1
	--● Shuffle 2 Dragon monsters from your GY into the Deck, then add 1 Field Spell from your GY to your hand
	local b2=not Duel.HasFlagEffect(tp,id+100) and #dg>=2 
		and Duel.IsExistingMatchingCard(aux.AND(Card.IsFieldSpell,Card.IsAbleToHand),tp,LOCATION_GRAVE,0,1,nil)
	--● Shuffle 3 Dragon monsters from your GY into the Deck, then shuffle up to 3 monsters from your opponent's GY into the Deck
	local b3=not Duel.HasFlagEffect(tp,id+200) and #dg>=3 
		and Duel.IsExistingMatchingCard(aux.AND(Card.IsMonster,Card.IsAbleToDeck),tp,0,LOCATION_GRAVE,1,nil)
	if chk==0 then return b1 or b2 or b3 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b3,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
		Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		e:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
		Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE|PHASE_END,0,1)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_GRAVE)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	elseif op==3 then
		e:SetCategory(CATEGORY_TODECK)
		Duel.RegisterFlagEffect(tp,id+200,RESET_PHASE|PHASE_END,0,1)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,4,PLAYER_ALL,LOCATION_GRAVE)
	end
end
function s.spfilter(c,e,tp,code)
	return c:IsSetCard(SET_ROKKET) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local dg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil)
	if op==1 then
		--● Shuffle 1 Dragon monster from your GY into the Deck, then you can Special Summon 1 "Rokket" monster with a different name from your Deck
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local gc=dg:Select(tp,1,1,nil):GetFirst()
		if not gc then return end
		Duel.HintSelection(gc)
		if Duel.SendtoDeck(gc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp,gc:GetCode())
		if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=sg:Select(tp,1,1,nil)
			if sc then
				Duel.BreakEffect()
				Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	elseif op==2 then
		--● Shuffle 2 Dragon monsters from your GY into the Deck, then add 1 Field Spell from your GY to your hand
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=dg:Select(tp,2,2,nil)
		if #g~=2 then return end
		Duel.HintSelection(g)
		if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local hg=Duel.SelectMatchingCard(tp,aux.AND(Card.IsFieldSpell,Card.IsAbleToHand),tp,LOCATION_GRAVE,0,1,1,nil)
		if #hg>0 then
			Duel.HintSelection(hg)
			Duel.BreakEffect()
			Duel.SendtoHand(hg,nil,REASON_EFFECT)
		end
	elseif op==3 then
		--● Shuffle 3 Dragon monsters from your GY into the Deck, then shuffle up to 3 monsters from your opponent's GY into the Deck
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=dg:Select(tp,3,3,nil)
		if #g~=3 then return end
		Duel.HintSelection(g)
		if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sg=Duel.SelectMatchingCard(tp,aux.AND(Card.IsMonster,Card.IsAbleToDeck),tp,0,LOCATION_GRAVE,1,3,nil)
		if #sg>0 then
			Duel.HintSelection(sg)
			Duel.BreakEffect()
			Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end