--ＶＳトリニティ・バースト
--Vanquish Soul - Trinity Burst
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END+TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_VANQUISH_SOUL}
function s.tgfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(SET_VANQUISH_SOUL)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,c:GetOriginalAttribute())
end
function s.spfilter(c,e,tp,att)
	return c:IsSetCard(SET_VANQUISH_SOUL) and c:GetOriginalAttribute()~=att
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() or ft<=0 then return end
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp,tc:GetOriginalAttribute())
	if #g==0 then return end
	local ct=math.min(2,ft)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ct=1 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,ct,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
	local og=Group.CreateGroup()
	for sc in sg:Iter() do
		if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
			--Negate their effects
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			sc:RegisterEffect(e2)
			og:AddCard(sc)
		end
	end
	if Duel.SpecialSummonComplete()==0 then return end
	if #og>0 then
		aux.DelayedOperation(og,PHASE_END,id,e,tp,function(ag) Duel.SendtoHand(ag,nil,REASON_EFFECT) end,nil,0)
		local thg=Group.CreateGroup()
		for oc in (og+tc):Iter() do
			thg:Merge(oc:GetColumnGroup():Filter(s.thfilter,nil,1-tp))
		end
		if #thg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.SendtoHand(thg,nil,REASON_EFFECT)
		end
	end
end
function s.thfilter(c,p)
	return c:IsAbleToHand() and c:IsControler(p)
end