--Elemelon Tiller
--AlphaKretin
function c210310011.initial_effect(c)
	c:EnableCounterPermit(0x20)
	c:SetCounterLimit(0x20,6)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetCountLimit(1)
	e2:SetValue(c210310011.valcon)
	c:RegisterEffect(e2)
	--counter on summon
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(c210310011.counter)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e5)
	--counter on act
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetCode(EVENT_CHAINING)
	e6:SetRange(LOCATION_SZONE)
	e6:SetOperation(aux.chainreg)
	c:RegisterEffect(e6)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e6:SetCode(EVENT_CHAIN_SOLVING)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetRange(LOCATION_SZONE)
	e6:SetOperation(c210310011.ctop)
	c:RegisterEffect(e6)
	--move
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(4031,10))
	e7:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e7:SetType(EFFECT_TYPE_QUICK_O)
	e7:SetCode(EVENT_FREE_CHAIN)
	e7:SetRange(LOCATION_SZONE)
	e7:SetCost(c210310011.seqcost)
	e7:SetTarget(c210310011.seqtg)
	e7:SetOperation(c210310011.seqop)
	c:RegisterEffect(e7)
	--return
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(4031,11))
	e8:SetCategory(CATEGORY_TOGRAVE)
	e8:SetType(EFFECT_TYPE_IGNITION)
	e8:SetRange(LOCATION_SZONE)
	e8:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e8:SetCost(c210310011.rtgcost)
	e8:SetTarget(c210310011.rtgtg)
	e8:SetOperation(c210310011.rtgop)
	c:RegisterEffect(e8)
end
function c210310011.valcon(e,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0
end
function c210310011.cfilter(c)
	return c:IsSetCard(0xf31)
end
function c210310011.counter(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c210310011.cfilter,1,nil) then
		e:GetHandler():AddCounter(0x20,1)
	end
end
function c210310011.ctop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0xf31) and e:GetHandler():GetFlagEffect(1)>0 then
		e:GetHandler():AddCounter(0x20,1)
	end
end
function c210310011.seqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x20,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x20,1,REASON_COST)	
end
function c210310011.seqfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xf31)
end
function c210310011.seqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c210310011.seqfilter(chkc,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c210310011.seqfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(4031,12))
	Duel.SelectTarget(tp,c210310011.seqfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
function c210310011.seqop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) then return end
	local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	local nseq=0
	if s==1 then nseq=0
	elseif s==2 then nseq=1
	elseif s==4 then nseq=2
	elseif s==8 then nseq=3
	else nseq=4 end
	Duel.MoveSequence(tc,nseq)
end
function c210310011.rtgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x20,3,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x20,3,REASON_COST)	
end
function c210310011.rtgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf31) and c:IsType(TYPE_MONSTER)
end
function c210310011.rtgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c210310011.rtgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c210310011.rtgfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,c210310011.rtgfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
function c210310011.rtgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and e:GetHandler():IsRelateToEffect(e) then
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_RETURN)
	end
end
