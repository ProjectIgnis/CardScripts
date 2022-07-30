--Ｕ．Ａ．ターンオーバー・タクティクス
--U.A. Turnover Tactics
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	c:RegisterEffect(e1)
end
s.listed_series={0xb2}

function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb2)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	return g:GetClassCount(Card.GetCode)>=2
end
function s.filter(c,e,tp)
	return c:IsSetCard(0xb2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.mzfilter(c,tp)
	return c:GetSequence()<5 and c:IsControler(tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)+g:FilterCount(s.mzfilter,nil,tp)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_DECK)
end
function s.locfilter(c,sp)
	return c:IsLocation(LOCATION_DECK) and c:IsControler(sp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	Duel.ShuffleDeck(tp)
	local ct1=Duel.GetOperatedGroup():FilterCount(s.locfilter,nil,tp)
	local ct2=Duel.GetOperatedGroup():FilterCount(s.locfilter,nil,1-tp)
	if ct1>Duel.GetLocationCount(tp,LOCATION_MZONE) then ct1=Duel.GetLocationCount(tp,LOCATION_MZONE) end
	if ct2>Duel.GetLocationCount(1-tp,LOCATION_MZONE) then ct2=Duel.GetLocationCount(1-tp,LOCATION_MZONE) end
	if ct1<=0 then return end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if #g==0 then return end
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:Select(tp,1,1,nil)
	g:Remove(Card.IsCode,nil,sg:GetFirst():GetCode())
	ct1=ct1-1
	while ct1>0 and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g1=g:Select(tp,1,1,nil)
		g:Remove(Card.IsCode,nil,g1:GetFirst():GetCode())
		sg:Merge(g1)
		ct1=ct1-1
	end
	local sc=sg:GetFirst()
	for sc in aux.Next(sg) do
		if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
			--Cannot attack this turn
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(3206)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			sc:RegisterEffect(e1)
		end
	end
	Duel.SpecialSummonComplete()
	if ct2>0 and Duel.IsExistingMatchingCard(Card.IsCanBeSpecialSummoned,tp,0,LOCATION_DECK,1,nil,e,0,1-tp,false,false)
		and Duel.SelectYesNo(1-tp,aux.Stringid(id,2)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
		local sg2=Duel.SelectMatchingCard(1-tp,Card.IsCanBeSpecialSummoned,tp,0,LOCATION_DECK,1,ct2,nil,e,0,1-tp,false,false)
		if #sg2>0 then
			Duel.SpecialSummon(sg2,0,1-tp,1-tp,false,false,POS_FACEUP)
		end
	end
end