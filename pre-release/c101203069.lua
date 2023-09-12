--マジェスペクター・ウィンド
--Majespecter Wind
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 "Majespecter" monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_MAJESPECTER}
function s.spcostfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_SPELLCASTER) and Duel.GetMZoneCount(tp,c)>0
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_MAJESPECTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=LOCATION_HAND|LOCATION_GRAVE
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local cost_chk=e:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.CheckReleaseGroupCost(tp,s.spcostfilter,1,false,nil,nil,e,tp)
	if chk==0 then return (cost_chk or ft>0)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,loc|(cost_chk and LOCATION_DECK or 0),0,1,nil,e,tp)
	end
	if cost_chk and (ft<1 or Duel.SelectYesNo(tp,aux.Stringid(id,1))) then
		local g=Duel.SelectReleaseGroupCost(tp,s.spcostfilter,1,1,false,nil,nil,e,tp)
		Duel.Release(g,REASON_COST)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc|LOCATION_DECK)
	else
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
	end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local _,_,_,_,loc=Duel.GetOperationInfo(0,CATEGORY_SPECIAL_SUMMON)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,loc,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end