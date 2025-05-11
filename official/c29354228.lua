--ドラグマ・エンカウンター
--Dogmatika Encounter
--Scripted by ahtelel
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_DOGMATIKA}
s.listed_names={CARD_ALBAZ}
function s.handspfilter(c,e,tp)
	return (c:IsSetCard(SET_DOGMATIKA) or c:IsCode(CARD_ALBAZ)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.thspfilter(c,e,tp,mzone_chk)
	return (c:IsSetCard(SET_DOGMATIKA) or c:IsCode(CARD_ALBAZ)) and c:IsMonster() and (c:IsAbleToHand()
		or (mzone_chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local mzone_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	local b1=mzone_chk and Duel.IsExistingMatchingCard(s.handspfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	local b2=Duel.IsExistingMatchingCard(s.thspfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,mzone_chk)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	elseif op==2 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
		Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Special Summon 1 "Dogmatika" monster or "Fallen of Albaz" from your hand
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.handspfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif op==2 then
		--Add to your hand or Special Summon 1 "Dogmatika" monster or "Fallen of Albaz" from your GY
		local mzone_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
		local sc=Duel.SelectMatchingCard(tp,s.thspfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,mzone_chk):GetFirst()
		if not sc then return end
		aux.ToHandOrElse(sc,tp,
			function() return mzone_chk and sc:IsCanBeSpecialSummoned(e,0,tp,false,false) end,
			function() Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP) end,
			aux.Stringid(id,4)
		)
	end
end
