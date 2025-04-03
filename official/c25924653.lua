--剣闘獣ダリウス
--Gladiator Beast Darius
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 "Gladiator Beast" monster from your GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(aux.gbspcon)
	e1:SetTarget(s.gysptg)
	e1:SetOperation(s.gyspop)
	c:RegisterEffect(e1)
	--Special Summon 1 "Gladiator Beast" monster from your Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE|PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function(e) return e:GetHandler():GetBattledGroupCount()>0 end)
	e2:SetCost(Cost.SelfToDeck)
	e2:SetTarget(s.dsptg)
	e2:SetOperation(s.dspop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_GLADIATOR_BEAST}
s.listed_names={id}
function s.gyspfilter(c,e,tp)
	return c:IsSetCard(SET_GLADIATOR_BEAST) and c:IsCanBeSpecialSummoned(e,104,tp,false,false)
end
function s.gysptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.gyspfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.gyspfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.gyspfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.gyspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,104,tp,tp,false,false,POS_FACEUP) then
		tc:NegateEffects(c)
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			c:SetCardTarget(tc)
			--Register when this card is about the leave the field
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_LEAVE_FIELD_P)
			e1:SetOperation(s.regop)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			c:RegisterEffect(e1)
		end
	end
	Duel.SpecialSummonComplete()
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetFirstCardTarget()
	if not (tc and tc:IsLocation(LOCATION_MZONE)) then return end
	--Shuffle it into the Deck when this card leaves the field
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
	e:Reset()
end
function s.dspfilter(c,e,tp)
	return c:IsSetCard(SET_GLADIATOR_BEAST) and c:IsCanBeSpecialSummoned(e,104,tp,false,false) and not c:IsCode(id)
end
function s.dsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		and Duel.IsExistingMatchingCard(s.dspfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.dspop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.dspfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if sc and Duel.SpecialSummon(sc,104,tp,tp,false,false,POS_FACEUP)>0 then
		sc:RegisterFlagEffect(sc:GetOriginalCode(),RESET_EVENT|RESETS_STANDARD_DISABLE,0,0)
	end
end