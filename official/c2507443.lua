--プリマの光
--Prima Light
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
	--Add 1 Warrior or Fairy "Cyber" monster from your Deck to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_CYBER}
function s.tribfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_WARRIOR) and c:IsReleasableByEffect() and Duel.GetMZoneCount(tp,c)>0
end
function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_WARRIOR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.nsfilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsSummonable(true,nil)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.CheckReleaseGroup(tp,s.tribfilter,1,nil,tp)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp)
	local b2=Duel.IsMainPhase() and Duel.IsExistingMatchingCard(s.nsfilter,tp,LOCATION_HAND,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_MZONE)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
	elseif op==2 then
		e:SetCategory(CATEGORY_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Tribute 1 EARTH Warrior monster, and if you do, Special Summon 1 LIGHT Warrior monster from your hand or Deck
		local rg=Duel.SelectReleaseGroup(tp,s.tribfilter,1,1,nil,tp)
		if #rg>0 and Duel.Release(rg,REASON_EFFECT)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp)
			if #sg>0 then
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	elseif op==2 then
		--Immediately after this effect resolves, Normal Summon 1 Warrior monster from your hand
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.nsfilter,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
		if sc then
			Duel.Summon(tp,sc,true,nil)
		end
	end
end
function s.thfilter(c)
	return c:IsRace(RACE_WARRIOR|RACE_FAIRY) and c:IsSetCard(SET_CYBER) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end