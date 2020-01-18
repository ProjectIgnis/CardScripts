--方界曼荼羅
--Cubic Mandala
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_COUNTER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_END_PHASE,TIMING_END_PHASE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--disable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_CHAIN_ACTIVATING)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	--destroy
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(s.descon)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
s.counter_place_list={0x1038}
s.listed_series={0xe3}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsSetCard,0xe3),tp,LOCATION_MZONE,0,1,nil)
end
function s.spfilter(c,e,tp,tid)
	return c:IsReason(REASON_DESTROY) and c:IsType(TYPE_MONSTER) and c:GetTurnID()==tid
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
		and Duel.IsCanAddCounter(tp,0x1038,1,c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tid=Duel.GetTurnCount()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and s.spfilter(chkc,e,tp,tid) end
	local ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)
	if chk==0 then return ft>0
		and Duel.IsExistingTarget(s.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp,tid) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local g=Duel.SelectTarget(tp,s.spfilter,tp,0,LOCATION_GRAVE,1,ft,nil,e,tp,tid)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)
	if ft<=0 or not c:IsRelateToEffect(e) then return end
	local sg=Duel.GetTargetCards(e)
	if #sg>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	if #sg>ft then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		sg=sg:Select(tp,ft,ft,nil)
	end
	local sc=sg:GetFirst()
	for sc in aux.Next(sg) do
		if Duel.SpecialSummonStep(sc,0,tp,1-tp,false,false,POS_FACEUP) then
			c:SetCardTarget(sc)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e1)
		end
	end
	Duel.SpecialSummonComplete()
	local og=Duel.GetOperatedGroup()
	local oc=og:GetFirst()
	for oc in aux.Next(og) do
		oc:AddCounter(0x1038,1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_ATTACK)
		e2:SetCondition(s.disable)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		oc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_DISABLE)
		oc:RegisterEffect(e3)
	end
end
function s.disable(e)
	return e:GetHandler():GetCounter(0x1038)>0
end
function s.dfilter(c,g)
	return g:IsContains(c)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetCardTarget()
	if re:IsActiveType(TYPE_MONSTER) and rp~=tp
		and Duel.IsExistingMatchingCard(s.dfilter,tp,0,LOCATION_MZONE,1,nil,g) then
		Duel.NegateEffect(ev)
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetCardTarget()
	return eg:FilterCount(s.dfilter,nil,g)>0
		and not Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,g)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
