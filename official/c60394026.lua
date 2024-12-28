--ライゼオル・プラグイン
--Ryzeal Plugin
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 Xyz Monster or "Ryzeal" monster from your GY or banishment
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_RYZEAL}
function s.spfilter(c,e,tp)
	return (c:IsType(TYPE_XYZ) or c:IsSetCard(SET_RYZEAL)) and c:IsFaceup()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
end
function s.attachfilter(c,tp)
	return c:IsSetCard(SET_RYZEAL) and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil,c,tp)
end
function s.xyzfilter(c,mc,tp)
	return c:IsType(TYPE_XYZ) and c:IsRank(4) and c:IsFaceup() and mc:IsCanBeXyzMaterial(c,tp,REASON_EFFECT)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0
		and Duel.IsExistingMatchingCard(s.attachfilter,tp,LOCATION_DECK,0,1,nil,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
		local mc=Duel.SelectMatchingCard(tp,s.attachfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local xyzc=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,mc,tp):GetFirst()
		if not xyzc:IsImmuneToEffect(e) then
			Duel.BreakEffect()
			Duel.Overlay(xyzc,mc)
		end
	end
	local c=e:GetHandler()
	--You cannot declare attacks for the rest of this turn, except with Rank 4 Xyz Monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) return not (c:IsType(TYPE_XYZ) and c:IsRank(4)) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(c,0,tp,1,0,aux.Stringid(id,2))
end