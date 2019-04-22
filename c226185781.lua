--Daigusto Omindaar
function c226185781.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x10),2)
	--add to hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c226185781.thcon)
	e1:SetTarget(c226185781.thtg)
	e1:SetOperation(c226185781.thop)
	c:RegisterEffect(e1)
	--unnafected
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c226185781.titg)
	e2:SetValue(c226185781.tval)
	c:RegisterEffect(e2)
	--shuffle and special summon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,226185781)
	e3:SetTarget(c226185781.thsptg)
	e3:SetOperation(c226185781.thspop)
	c:RegisterEffect(e3)
end
function c226185781.thcon(e,tp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function c226185781.thfilter(c)
	return c:IsSetCard(0x10) and c:IsAbleToHand()
end
function c226185781.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c226185781.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c226185781.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,c226185781.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_GRAVE)
end
function c226185781.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and not tc:IsHasEffect(EFFECT_NECRO_VALLEY) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
function c226185781.titg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c) and (c:IsSetCard(0x1010) or c:IsCode(581014,2766877,10755984,29552709,34109611,84766279,210310250))
end
function c226185781.tval(e,re)
	return e:GetHandler()~=re:GetOwner() and re:IsActivated()
end
function c226185781.spfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c226185781.thsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c226185781.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		and Duel.IsExistingMatchingCard(c226185781.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c226185781.thspop(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local td=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c226185781.thfilter),tp,LOCATION_GRAVE,0,1,3,nil)
	if td:GetCount()>0 and Duel.SendtoDeck(td,nil,0,REASON_EFFECT)>0 then
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=Duel.SelectMatchingCard(tp,c226185781.spfilter,tp,LOCATION_DECK,0,1,math.min(2,ft),nil,e,tp)
			if sg:GetCount()>0 then
				Duel.BreakEffect()
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end