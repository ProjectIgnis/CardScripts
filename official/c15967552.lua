--リトル・オポジション
--Small Scuffle
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 Level 2 or lower monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E|TIMING_MAIN_END)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
function s.spfilter(c,e,tp,zone)
	return c:IsLevelBelow(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK|POS_FACEDOWN_DEFENSE,tp,zone)
end
--implemented to only select a zone on tp's field since selecting
--the corresponding opponent zone is redundant (it's already checked)
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zones=0
	for seq=0,4 do
		local z1=1<<seq
		local z2=1<<(4-seq)
		if Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,z1)>0
			and Duel.GetLocationCount(1-tp,LOCATION_MZONE,1-tp,LOCATION_REASON_TOFIELD,z2)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp,z1) then
			zones=zones|z1
		end
	end
	if chk==0 then return zones>0 end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local zone=Duel.SelectFieldZone(tp,1,LOCATION_MZONE,0,ZONES_EMZ|~zones)
	Duel.SetTargetParam(zone)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_HAND|LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local z1=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local z2=1<<(4-math.log(z1,2))
	if Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,z1)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc1=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp,z1):GetFirst()
	if not sc1 or Duel.SpecialSummon(sc1,0,tp,tp,false,false,POS_FACEUP_ATTACK|POS_FACEDOWN_DEFENSE,z1)==0 then return end
	if sc1:IsFacedown() then Duel.ConfirmCards(1-tp,sc1) end
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE,1-tp,LOCATION_REASON_TOFIELD,z2)>0
		and Duel.IsExistingMatchingCard(s.spfilter,1-tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,1-tp,z2)
		and Duel.SelectYesNo(1-tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc2=Duel.SelectMatchingCard(1-tp,s.spfilter,1-tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,1-tp,z2):GetFirst()
		if not sc2 then return end
		Duel.BreakEffect()
		Duel.SpecialSummon(sc2,0,1-tp,1-tp,false,false,POS_FACEUP_ATTACK|POS_FACEDOWN_DEFENSE,z2)
		if sc2:IsFacedown() then Duel.ConfirmCards(tp,sc2) end
	end
end