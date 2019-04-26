--Istrakan Tech - Otenko Panel
function c210001511.initial_effect(c)
	c:SetUniqueOnField(1,0,210001511)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCost(c210001511.spcost)
	e2:SetTarget(c210001511.sptarget)
	e2:SetOperation(c210001511.spoperation)
	c:RegisterEffect(e2)
	--addtohand
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCondition(aux.exccon)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c210001511.thtarget)
	e3:SetOperation(c210001511.thoperation)
	c:RegisterEffect(e3)
end
function c210001511.cfilter(c)
	return (c:IsSetCard(0xf70) or c:IsSetCard(0xf71)) and c:IsDiscardable()
end
function c210001511.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210001511.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,c210001511.cfilter,1,1,REASON_DISCARD+REASON_COST,nil)
end
function c210001511.spfilter(c,e,tp)
	return c:IsCode(210001502) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c210001511.sptarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c210001511.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
function c210001511.spoperation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c210001511.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if g and #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c210001511.thfilter(c)
	return c:IsCode(210001511) and c:IsAbleToHand()
end
function c210001511.thtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210001511.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND+CATEGORY_SEARCH,nil,1,tp,LOCATION_DECK)
end
function c210001511.thoperation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c210001511.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g and #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end