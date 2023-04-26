--Japanese name
--Gold Pride - That Came Out of Nowhere!
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 "Gold Pride" monster from your hand or GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_GOLD_PRIDE}
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_GOLD_PRIDE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(Card.IsCanBeSpecialSummoned),1-tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,0,1-tp,false,false)
		and Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=Duel.SelectMatchingCard(1-tp,aux.NecroValleyFilter(Card.IsCanBeSpecialSummoned),1-tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,0,1-tp,false,false):GetFirst()
		if not tc then return end
		Duel.BreakEffect()
		if Duel.SpecialSummonStep(tc,0,1-tp,1-tp,false,false,POS_FACEUP) then
			tc:NegateEffects(e:GetHandler())
		end
		Duel.SpecialSummonComplete()
	end
end