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
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_DOGMATIKA}
s.listed_names={CARD_ALBAZ}
function s.albazdogmatikafilter(c)
	return (c:IsCode(CARD_ALBAZ) or (c:IsSetCard(SET_DOGMATIKA) and c:IsMonster()))
end
function s.thfilter(c)
	return s.albazdogmatikafilter(c) and c:IsAbleToHand()
end
function s.spfilter(c,e,tp)
	return s.albazdogmatikafilter(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.thspfilter(c,ft,e,tp)
	return s.thfilter(c) or (ft>0 and s.spfilter(c,e,tp))
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	local b1=ft>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	local b2=Duel.IsExistingMatchingCard(s.thspfilter,tp,LOCATION_GRAVE,0,1,nil,ft,e,tp)
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
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
		Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Special Summon 1 "Dogmatika" monster or "Fallen of Albaz" from your hand.
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif op==2 then
		--Add to your hand or Special Summon 1 "Dogmatika" monster or "Fallen of Albaz" from your GY
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
		local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thspfilter),tp,LOCATION_GRAVE,0,1,1,nil,ft,e,tp):GetFirst()
		if sc then
			aux.ToHandOrElse(sc,tp,function(c)
				return sc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) and ft>0 end,
			function(c)
				Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP) end,
			aux.Stringid(id,4))
		end
	end
end