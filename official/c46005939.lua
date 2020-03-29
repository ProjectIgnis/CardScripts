--ペンデュラム・エクシーズ
--Pendulum Xyz
--Scripted by Eerie Code, based on anime version by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,e,tp)
	return c:IsFaceup() and c:GetLevel()>0 and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spfilter(c,mg,lv)
	mg:ForEach(function(mc)
		mc:AssumeProperty(ASSUME_TYPE,mc:GetOriginalType())
		mc:AssumeProperty(ASSUME_LEVEL,lv)
	end)
	return c:IsXyzSummonable(nil,mg,2,2)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_PZONE,0,nil,e,tp)
	if chk==0 then
		if not (#g==2 and Duel.IsPlayerCanSpecialSummonCount(tp,2)
			and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>1) then return false end
		local tc1=g:GetFirst()
		local tc2=g:GetNext()
		local r1=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,g,tc1:GetLevel())
		Duel.AssumeReset()
		local r2=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,g,tc2:GetLevel())
		Duel.AssumeReset()
		return r1 or r2
	end
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
function s.filter2(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(s.filter2,nil,e,tp)
	if #g<2 then return end
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
	Duel.SpecialSummonComplete()
	Duel.BreakEffect()
	local lv1=g:GetFirst():GetLevel()
	local lv2=g:GetNext():GetLevel()
	local g1=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,g,lv1)
	local g2=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,g,lv2)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local xyz=(g1+g2):Select(tp,1,1,nil):GetFirst()
	if xyz then
		if not s.spfilter(xyz,g,lv1) then s.spfilter(xyz,g,lv2) end
		Duel.XyzSummon(tp,xyz,nil,g)
		Duel.AssumeReset()
	end
end
