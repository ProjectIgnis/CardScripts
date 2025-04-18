--忍法 超変化の術
--Ninjitsu Art of Super-Transformation
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Destroy
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_NINJA}
function s.filter1(c,tp,slv,ft)
	local lv1=c:GetLevel()
	return c:IsFaceup() and c:IsSetCard(SET_NINJA) and lv1>0 and (ft>0 or c:GetSequence()<5)
		and Duel.IsExistingTarget(s.filter2,tp,0,LOCATION_MZONE,1,nil,lv1,slv)
end
function s.filter2(c,lv1,slv)
	local lv2=c:GetLevel()
	return c:IsFaceup() and lv2>0 and lv1+lv2>=slv
end
function s.spfilter(c,e,tp,lv)
	return c:IsRace(RACE_DRAGON|RACE_DINOSAUR|RACE_SEASERPENT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (not lv or c:IsLevelBelow(lv))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then
		if #sg==0 then return false end
		local mg,mlv=sg:GetMinGroup(Card.GetLevel)
		return ft>-1 and Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,0,1,nil,tp,mlv,ft)
	end
	local mg,mlv=sg:GetMinGroup(Card.GetLevel)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g1=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,tp,mlv,ft)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g2=Duel.SelectTarget(tp,s.filter2,tp,0,LOCATION_MZONE,1,1,nil,g1:GetFirst():GetLevel(),mlv)
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g1,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if #tg==0 then return end
	Duel.SendtoGrave(tg,REASON_EFFECT)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=tg:GetFirst()
	local lv=0
	if tc:IsLocation(LOCATION_GRAVE) then lv=lv+tc:GetLevel() end
	tc=tg:GetNext()
	if tc and tc:IsLocation(LOCATION_GRAVE) then lv=lv+tc:GetLevel() end
	if lv==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,lv)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		Duel.BreakEffect()
		c:SetCardTarget(tc)
		Duel.SpecialSummonComplete()
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end