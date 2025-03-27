--御巫の契り
--Mikanko Promise
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 "Mikanko" monster from hand or Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_MIKANKO}
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_MIKANKO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.eqfilter(c,tc,tp)
	return c:IsType(TYPE_EQUIP) and c:CheckEquipTarget(tc) and c:CheckUniqueOnField(tp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		--Banish it if it leaves the field
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e1)
		Duel.SpecialSummonComplete()
		--Equip the summoned monster with an appropriate Equip Spell
		if Duel.GetLocationCount(tp,LOCATION_SZONE)==0 then return end
		local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,nil,tc,tp)
		if #tg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
			local sg=tg:Select(tp,1,1,nil)
			Duel.BreakEffect()
			Duel.Equip(tp,sg:GetFirst(),tc)
		end
	end
end