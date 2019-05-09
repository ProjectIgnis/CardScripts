--Heimdallr of the Nordic Champions
--designed by Thaumablazer#4134, scripted by Naim
function c210777078.initial_effect(c)
	--link summon
	Link.AddProcedure(c,nil,2,2,c210777078.lcheck)
	c:EnableReviveLimit()
	--Special summon from gy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(210777078,0))
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)	
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,210777078)
	e1:SetCondition(c210777078.spcon)
	e1:SetTarget(c210777078.sptg)
	e1:SetOperation(c210777078.spop)
	c:RegisterEffect(e1)
	--Special Summon from deck
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,210777078+100)
	e2:SetCost(c210777078.spcost)
	e2:SetTarget(c210777078.sptg2)
	e2:SetOperation(c210777078.spop2)
	c:RegisterEffect(e2)
end
function c210777078.lcheck(g,lc,tp)
	return g:IsExists(Card.IsSetCard,1,nil,0x42,lc,SUMMON_TYPE_LINK,tp)
end
function c210777078.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function c210777078.filter(c,e,tp)
	return c:IsSetCard(0x42) and not c:IsCode(210777078) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function c210777078.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c210777078.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c210777078.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c210777078.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c210777078.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		if tc:IsType(TYPE_TUNER)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,210777083,0x42,0x4011,1000,1000,4,RACE_WARRIOR,ATTRIBUTE_EARTH)
		and Duel.SelectYesNo(tp,aux.Stringid(210777078,1)) then
			Duel.BreakEffect()
			local token=Duel.CreateToken(tp,210777083)
			Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function c210777078.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function c210777078.spfilter(c,e,tp)
	return  c:IsSetCard(0x42) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c210777078.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if e:GetHandler():GetSequence()<5 then ft=ft+1 end
	if chk==0 then return ft>0 and Duel.IsExistingMatchingCard(c210777078.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c210777078.spop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c210777078.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
