--
--The Revived Sky God
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	local EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF=EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Place 1 "Monster Reborn" on top of your Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_MONSTER_REBORN,10000020}
function s.spfilter(c,e,tp)
	return c:IsCode(10000020) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct1=6-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	local ct2=6-Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		and ct1>0 and Duel.IsPlayerCanDraw(tp,ct1)
		and ct2>0 and Duel.IsPlayerCanDraw(1-tp,ct2) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,ct1+ct2)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		local turn_p=Duel.GetTurnPlayer()
		local ct1=6-Duel.GetFieldGroupCount(turn_p,LOCATION_HAND,0)
		local ct2=6-Duel.GetFieldGroupCount(turn_p,0,LOCATION_HAND)
		if ct1<=0 and ct2<=0 then return end
		if not (Duel.IsPlayerCanDraw(tp) or Duel.IsPlayerCanDraw(1-tp)) then return end
		Duel.BreakEffect()
		if ct1>0 then
			Duel.Draw(turn_p,ct1,REASON_EFFECT)
		end
		if ct2>0 then
			Duel.Draw(1-turn_p,ct2,REASON_EFFECT)
		end
	end
end
function s.tdfilter(c,deck_count)
	if not c:IsCode(CARD_MONSTER_REBORN) then return false end
	if c:IsLocation(LOCATION_DECK) then
		return deck_count>1
	else
		return c:IsAbleToDeck()
	end
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local deck_count=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,deck_count) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local deck_count=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,deck_count):GetFirst()
	if not tc then return end
	if tc:IsLocation(LOCATION_DECK) then
		Duel.ShuffleDeck(tp)
		Duel.MoveToDeckTop(tc)
	else
		Duel.HintSelection(tc,true)
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
	if not ((tc:IsLocation(LOCATION_DECK) and Duel.GetDecktopGroup(tp,1):IsContains(tc)) or tc:IsLocation(LOCATION_EXTRA)) then return end
	Duel.ConfirmCards(1-tp,tc)
	if Duel.IsPlayerCanDraw(tp) and Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_GRAVE,0,1,nil,RACE_DIVINE) then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end