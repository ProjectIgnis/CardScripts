--壊獣の出現記録
--The Kaiju Files
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x37)
	c:SetCounterLimit(0x37,5)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--counter
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.counter)
	c:RegisterEffect(e2)
	--destroy
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
	--tohand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(s.thcon)
	e4:SetCost(s.thcost)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
s.counter_place_list={0x37}
s.listed_series={0xd3}
s.listed_names={id}
function s.cfilter(c)
	return c:IsSetCard(0xd3) and c:IsPreviousLocation(LOCATION_HAND+LOCATION_GRAVE)
end
function s.counter(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.cfilter,1,nil) then
		e:GetHandler():AddCounter(0x37,1)
	end
end
function s.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0xd3)
		and Duel.IsExistingMatchingCard(s.chkfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetControler(),c:GetOriginalCode())
end
function s.chkfilter(c,e,tp,cc,code)
	return c:IsSetCard(0xd3) and c:GetOriginalCode()~=code and
		not c:IsHasEffect(EFFECT_REVIVE_LIMIT) and Duel.IsPlayerCanSpecialSummon(tp,0,POS_FACEUP,cc,c)
end
function s.spfilter(c,e,tp,cc,code)
	return c:IsSetCard(0xd3) and not c:IsOriginalCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,cc)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,e,tp)
		or Duel.GetLocationCount(1-tp,LOCATION_MZONE)>-1
		and Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local cc=tc:GetControler()
	local code=tc:GetOriginalCode()
	if Duel.Destroy(tc,REASON_EFFECT)~=0 then
		if Duel.GetLocationCount(cc,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,cc,code)
		if #g>0 then
			Duel.BreakEffect()
			Duel.SpecialSummon(g,0,tp,cc,false,false,POS_FACEUP)
		end
	end
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x37)>=3
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.thfilter(c)
	return c:IsSetCard(0xd3) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
