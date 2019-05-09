--Cloudian - Cumulonimbus
--AlphaKretin
function c210310061.initial_effect(c)
	--fusion material
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0x18),2)
	c:EnableReviveLimit()
	--battle indestructable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--selfdes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetCondition(c210310061.sdcon)
	c:RegisterEffect(e2)
	--counters
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(90135989,0))
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c210310061.ctcon)
	e3:SetOperation(c210310061.ctop)
	c:RegisterEffect(e3)
	--atk
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetValue(c210310061.atkval)
	c:RegisterEffect(e4)
	--replace counters
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetRange(LOCATION_MZONE)
	e5:SetOperation(c210310061.ctop2)
	c:RegisterEffect(e5)
	--recover
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_TOHAND+CATEGORY_SUMMON)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,210310061)
	e6:SetCost(c210310061.thcost)
	e6:SetTarget(c210310061.thtg)
	e6:SetOperation(c210310061.thop)
	c:RegisterEffect(e6)
end
c210310061.material_setcode=0x18b
function c210310061.sdcon(e)
	return e:GetHandler():IsPosition(POS_FACEUP_DEFENSE)
end
function c210310061.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function c210310061.ctfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x18)
end
function c210310061.ctop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local ct=Duel.GetMatchingGroupCount(c210310061.ctfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if ct>0 then
		for tc in aux.Next(g) do
			tc:AddCounter(0x1019,ct)
		end
	end
end
function c210310061.atkval(e,c)
	return Duel.GetCounter(0,1,1,0x1019)*200
end
function c210310061.ctop2(e,tp,eg,ep,ev,re,r,rp)
	local ct=0
	for c in aux.Next(eg) do
		ct=ct+c:GetCounter(0x1019)
	end
	if ct>0 then
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		for i=1,ct do
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(83604828,1))
			local tc=g:Select(tp,1,1,nil):GetFirst()
			tc:AddCounter(0x1019,1)
		end
	end
end
function c210310061.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x1019,2,REASON_COST) end
	Duel.RemoveCounter(tp,1,1,0x1019,2,REASON_COST)
end
function c210310061.thfilter(c)
	return c:IsSetCard(0x18) and c:IsAbleToHand()
end
function c210310061.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c210310061.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c210310061.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c210310061.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c210310061.thofilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x18) and c:IsSummonable(true,nil)
end
function c210310061.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc and tc:IsRelateToEffect(e)) then return end
	if (Duel.SendtoHand(tc,nil,REASON_EFFECT)>0) and Duel.IsExistingMatchingCard(c210310061.thsfilter,tp,LOCATION_HAND,0,1,nil) and Duel.IsCanRemoveCounter(tp,1,1,0x1019,1,REASON_EFFECT) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(84530620,0)) then
		Duel.BreakEffect()
		if Duel.RemoveCounter(tp,1,1,0x1019,1,REASON_EFFECT) then
			local sg=Duel.SelectMatchingCard(tp,c210310061.thofilter,tp,LOCATION_HAND,0,1,1,nil)
			local sc=sg:GetFirst()
			Duel.Summon(tp,sc,true,nil)
		end
	end
end