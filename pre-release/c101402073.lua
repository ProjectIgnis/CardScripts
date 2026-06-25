--色鬼の蟲毒
--Asutra Insect Poison
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects;
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
end
s.listed_series={SET_ASUTRA}
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_ASUTRA) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	local mmz_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	--● Special Summon this card as a Normal Monster (Insect/Tuner/DARK/Level 1/ATK 0/DEF 0) (this card is NOT treated as a Trap), then immediately after this effect resolves, you can Synchro Summon 1 Synchro Monster
	local b1=mmz_chk and e:IsHasType(EFFECT_TYPE_ACTIVATE)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,SET_ASUTRA,TYPE_MONSTER|TYPE_NORMAL|TYPE_TUNER,0,0,1,RACE_INSECT,ATTRIBUTE_DARK)
	--● Target 1 "Asutra" monster in your GY; Special Summon it
	local b2=mmz_chk and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	local cd=e:GetChainData()
	cd.choice=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	if cd.choice==1 then
		--● Special Summon this card as a Normal Monster (Insect/Tuner/DARK/Level 1/ATK 0/DEF 0) (this card is NOT treated as a Trap), then immediately after this effect resolves, you can Synchro Summon 1 Synchro Monster
		e:SetProperty(0)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,0)
		Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	elseif cd.choice==2 then
		--● Target 1 "Asutra" monster in your GY; Special Summon it
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local cd=e:GetChainData()
	if cd.choice==1 then
		--● Special Summon this card as a Normal Monster (Insect/Tuner/DARK/Level 1/ATK 0/DEF 0) (this card is NOT treated as a Trap), then immediately after this effect resolves, you can Synchro Summon 1 Synchro Monster
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp,id,SET_ASUTRA,TYPE_MONSTER|TYPE_NORMAL|TYPE_TUNER,0,0,1,RACE_INSECT,ATTRIBUTE_DARK) then
			c:AddMonsterAttribute(TYPE_NORMAL|TYPE_TUNER)
			Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP)
			c:AddMonsterAttributeComplete()
		end
		if Duel.SpecialSummonComplete()==0 then return end
		local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=g:Select(tp,1,1,nil)
			Duel.SynchroSummon(tp,sg:GetFirst())
		end
	elseif cd.choice==2 then
		--● Target 1 "Asutra" monster in your GY; Special Summon it
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end