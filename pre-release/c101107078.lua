-- トライブ・ドライブ
-- Tribe Drive
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Add to hand or Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.thspcon)
	e1:SetOperation(s.thspop)
	c:RegisterEffect(e1)
end
function s.getfieldraces(tp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local races=0
	for tc in aux.Next(g) do
		races=races|tc:GetRace()
	end
	local pop,count=races,0
	while pop>0 do
		if (pop&1)>0 then count=count+1 end
		pop=pop>>1
	end
	return races,count
end
function s.thspfilter(c,e,tp,ft,races)
	return c:IsRace(races) and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.thsprescon(sg)
	return sg:GetClassCount(Card.GetRace)==#sg
end
function s.thspcon(e,tp,eg,ep,ev,re,r,rp,chk)
	local races,count=s.getfieldraces(tp)
	if count<3 then return false end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=Duel.GetMatchingGroup(s.thspfilter,tp,LOCATION_DECK,0,nil,e,tp,ft,races)
	return aux.SelectUnselectGroup(g,e,tp,3,3,s.thsprescon,0)
end
function s.thspop(e,tp,eg,ep,ev,re,r,rp)
	local races,count=s.getfieldraces(tp)
	if count<3 then return end
	Duel.DisableShuffleCheck()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=Duel.GetMatchingGroup(s.thspfilter,tp,LOCATION_DECK,0,nil,e,tp,ft,races)
	local sg=aux.SelectUnselectGroup(g,e,tp,3,3,s.thsprescon,1,tp,HINTMSG_CONFIRM)
	if #sg~=3 then return end
	Duel.ConfirmCards(1-tp,sg)
	Duel.ShuffleDeck(tp)
	local sc=sg:RandomSelect(1-tp,1):GetFirst()
	if not sc then return end
	Duel.ConfirmCards(1-tp,sc)
	aux.ToHandOrElse(sc,tp,
		function(sc)
			return ft>0 and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		end,
		function(sc)
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end,
		aux.Stringid(id,1))
	sg=sg-sc
	if #sg>0 then
		Duel.MoveToDeckBottom(sg,tp)
		Duel.SortDeckbottom(tp,tp,#sg)
	end
end