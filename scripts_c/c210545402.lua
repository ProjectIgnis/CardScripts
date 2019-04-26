--Protector Priest Shimon 210545402
function c210545402.initial_effect(c)
	--synchro summon
	aux.AddSynchroProcedure(c,nil,1,1,aux.NonTunerEx(Card.IsSetCard,0x40),1,99)
	c:EnableReviveLimit()
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c210545402.con)
	e1:SetTarget(c210545402.destg)
	e1:SetOperation(c210545402.desop)
	c:RegisterEffect(e1)
	--synchro custom
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c210545402.syntarget)
	e2:SetOperation(c210545402.synoperation)
	c:RegisterEffect(e2)
end
function c210545402.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SYNCHRO
end
function c210545402.thfilter(c)
	return c:IsSetCard(0xde) or c:IsCode(64043465) and c:IsAbleToHand()
end
function c210545402.filter(c)
	return c:IsSetCard(0x40) and c:IsAbleToGrave()
end
function c210545402.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210545402.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil)
		and Duel.IsExistingMatchingCard(c210545402.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c210545402.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c210545402.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,c210545402.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
function c210545402.mgfilter(c)
	return (c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and not c:IsType(TYPE_TUNER) and c:GetLevel()~=0)
		or (c:IsLocation(LOCATION_DECK) and c:IsSetCard(0x40))
end
function c210545402.spfilter1(c,e,tp,lv)
	return Duel.GetLocationCountFromEx(tp,tp,sg,c) and c:IsType(TYPE_SYNCHRO) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function c210545402.rescon(sg,e,tp,mg)
	local lv=sg:GetSum(Card.GetOriginalLevel)+e:GetHandler():GetOriginalLevel()
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
		and Duel.IsExistingMatchingCard(c210545402.spfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,lv)
end
function c210545402.syntarget(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg=Duel.GetMatchingGroup(c210545402.mgfilter,tp,LOCATION_DECK+LOCATION_MZONE,0,nil)
	if chk==0 then return aux.SelectUnselectGroup(mg,e,tp,1,99,c210545402.rescon,0) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c210545402.spfilter2(c,e,tp,lv)
	return c:IsType(TYPE_SYNCHRO) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function c210545402.synoperation(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetMatchingGroup(c210545402.mgfilter,tp,LOCATION_DECK+LOCATION_MZONE,0,nil)
	if aux.SelectUnselectGroup(mg,e,tp,1,99,c210545402.rescon,0) then
		local sg=aux.SelectUnselectGroup(mg,e,tp,1,99,c210545402.rescon,1,tp,HINTMSG_TOGRAVE)
		sg:AddCard(e:GetHandler())
		if Duel.SendtoGrave(sg,REASON_EFFECT)>0 then
			local syg=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
			local lv=syg:GetSum(Card.GetOriginalLevel)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local ssg=Duel.SelectMatchingCard(tp,c210545402.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lv)
			local sc=ssg:GetFirst()
			if sc then
				Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
				sc:CompleteProcedure()
			end
		end
	end
end