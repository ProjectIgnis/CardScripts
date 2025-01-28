--罪なき罪宝
--Sinless Sinful Spoils
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_DIABELL}
function s.diabellspfilter(c,e,tp)
	return c:IsSetCard(SET_DIABELL) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spfilter(c,e,tp)
	return c:IsMonsterCard() and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if not chkc:IsControler(tp) then return false end
		local label=e:GetLabel()
		if label==1 then
			return chkc:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and s.diabellspfilter(chkc,e,tp)
		elseif label==2 then
			return chkc:IsLocation(LOCATION_STZONE) and s.spfilter(chkc,e,tp)
		end
	end
	local mzone_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	local b1=mzone_chk and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil,REASON_EFFECT)
		and Duel.IsExistingTarget(s.diabellspfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp)
	local b2=mzone_chk and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_STZONE,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	local g=nil
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	if op==1 then
		e:SetCategory(CATEGORY_HANDES+CATEGORY_SPECIAL_SUMMON)
		g=Duel.SelectTarget(tp,s.diabellspfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp)
		Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	elseif op==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_STZONE,0,1,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Special Summon 1 "Diabell" monster from your GY or banishment
		local tc=Duel.GetFirstTarget()
		if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT|REASON_DISCARD)>0 and tc:IsRelateToEffect(e) then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif op==2 then
		--Special Summon 1 face-up Monster Card from your Spell & Trap Zone
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end