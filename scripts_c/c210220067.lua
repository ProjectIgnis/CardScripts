--オッドアイズ・カタストロフ
--Odd-Eyes Catastrophe
--Created and scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK) and c:GetSequence()<5
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLP(tp)>100 end
	Duel.SetLP(tp,100)
end
function s.rmfilter1(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsAbleToRemove()
		and c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:IsType(TYPE_TUNER)
		and Duel.IsExistingTarget(s.rmfilter2,tp,LOCATION_MZONE,0,1,nil,e,tp,c)
end
function s.rmfilter2(c,e,tp,tc)
	if c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsAbleToRemove()
		and c:IsSummonType(SUMMON_TYPE_PENDULUM) and not c:IsType(TYPE_TUNER)
		and Duel.GetLocationCountFromEx(tp,tp,Group.FromCards(c,tc))>2 then
		local g=Group.FromCards(tc,c)
		local fb=Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,g)
		local sb=Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_EXTRA,0,1,nil,g)
		if c:GetLevel()==tc:GetLevel() then
			return fb and sb and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,g)
		else
			local lv1=c:GetLevel()
			local lv2=tc:GetLevel()
			if lv1>lv2 then
				tc:AssumeProperty(ASSUME_LEVEL,lv1)
			else
				c:AssumeProperty(ASSUME_LEVEL,lv2)
			end
			local x1=Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,Group.FromCards(c,tc))
			tc:AssumeProperty(ASSUME_LEVEL,lv1+lv2)
			c:AssumeProperty(ASSUME_LEVEL,lv1+lv2)
			local x2=Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,Group.FromCards(c,tc))
			Duel.AssumeReset()
			return fb and sb and (x1 or x2)
		end
	else
		return false
	end
end
function s.fusfilter(c,e,tp,mg)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_DRAGON)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and c:CheckFusionMaterial(mg,nil,tp)
end
function s.synfilter(c,mg)
	return c:IsRace(RACE_DRAGON) and c:IsSynchroSummonable(nil,mg)
end
function s.xyzfilter(c,mg)
	return c:IsRace(RACE_DRAGON) and c:IsXyzSummonable(mg,2,2)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter1,tp,LOCATION_MZONE,0,1,nil,e,tp) 
		and (not (c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]) or c29724053[tp]>=3)
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=2 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tn=Duel.SelectTarget(tp,s.rmfilter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp):GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local ntn=Duel.SelectTarget(tp,s.rmfilter2,tp,LOCATION_MZONE,0,1,1,tn,e,tp,tn):GetFirst()
	local g=Group.FromCards(tn,ntn)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()~=2 or Duel.GetLocationCountFromEx(tp,tp,g)<3 then return end
	local fg=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_EXTRA,0,nil,e,tp,g)
	local sg=Duel.GetMatchingGroup(s.synfilter,tp,LOCATION_EXTRA,0,nil,g)
	local xg=nil
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	local lv1=tc1:GetLevel()
	local lv2=tc2:GetLevel()
	if lv1==lv2 then
		xg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,g)
	else
		if lv1>lv2 then
			tc2:AssumeProperty(ASSUME_LEVEL,lv1)
		else
			tc1:AssumeProperty(ASSUME_LEVEL,lv2)
		end
		xg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,g)
		tc2:AssumeProperty(ASSUME_LEVEL,lv1+lv2)
		tc1:AssumeProperty(ASSUME_LEVEL,lv1+lv2)
		local x2=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,g)
		Duel.AssumeReset()
		xg:Merge(x2)
	end
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)==2 and fg:GetCount()>0 and sg:GetCount()>0 and xg:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local fc=fg:Select(tp,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=sg:Select(tp,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local xc=xg:Select(tp,1,1,nil)
		if Duel.SpecialSummon(fc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)~=0
			and Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)~=0
			and Duel.SpecialSummon(xc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)~=0
			and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=2 then
			Duel.BreakEffect()
			local mg=Duel.GetDecktopGroup(tp,2)
			Duel.Overlay(xc,mg)
		end
	end
end
