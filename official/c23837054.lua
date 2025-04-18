--溟界の呼び蛟
--Ogdoadic Calling
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_names={23837055}
s.listed_series={SET_OGDOADIC}
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_REPTILE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.setfitler(c)
	return c:IsSetCard(SET_OGDOADIC) and c:IsMonster()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
		local g=Duel.GetMatchingGroup(s.setfitler,tp,LOCATION_GRAVE,0,nil)
		local gysummon=g:GetClassCount(Card.GetCode)>=8 and sg:GetClassCount(Card.GetCode)>=2
		local tksummon=Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,SET_OGDOADIC,TYPES_TOKEN,0,0,2,RACE_REPTILE,ATTRIBUTE_DARK)
		return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and (tksummon or gysummon)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
	local g=Duel.GetMatchingGroup(s.setfitler,tp,LOCATION_GRAVE,0,nil)
	local gysummon=g:GetClassCount(Card.GetCode)>=8 and sg:GetClassCount(Card.GetCode)>=2
	local tksummon=Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,SET_OGDOADIC,TYPES_TOKEN,0,0,2,RACE_REPTILE,ATTRIBUTE_DARK)
	--Choose option
	local choice
	if tksummon and gysummon then
		choice=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif tksummon then choice=0
	elseif gysummon then choice=1
	else return end
	--Apply effect
	if choice==0 then
		for i=1,2 do
			local token=Duel.CreateToken(tp,id+1)
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		end
		Duel.SpecialSummonComplete()
	elseif choice==1 then
		local ssg=aux.SelectUnselectGroup(sg,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
		if ssg and #ssg>0 then
			Duel.SpecialSummon(ssg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end