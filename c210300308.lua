--Youkai Mirage, Kenmu
function c210300308.initial_effect(c)
	aux.EnableDualAttribute(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25206027,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c210300308.spcon)
	e1:SetTarget(c210300308.sptg)
	e1:SetOperation(c210300308.spop)
	e1:SetCountLimit(1,210300308)
	c:RegisterEffect(e1)
	--on release
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetOperation(c210300308.checkop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_RELEASE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCondition(c210300308.rcon)
	e3:SetTarget(c210300308.rtg)
	e3:SetOperation(c210300308.rop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	--cannot be target
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(c210300308.tgtg)
	e4:SetValue(c210300308.indval)
	c:RegisterEffect(e4)
	--indes
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	c:RegisterEffect(e5)
end
function c210300308.spfilter(c,tp)
	return c:IsReason(REASON_DESTROY) and c:IsType(TYPE_DUAL) and c:IsType(TYPE_MONSTER)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousControler()==tp
end
function c210300308.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c210300308.spfilter,1,nil,tp)
end
function c210300308.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c210300308.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
function c210300308.checkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsDisabled() and c:IsDualState() and c:IsReason(REASON_RELEASE) then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
function c210300308.rcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()==1
end
function c210300308.cfilter(c)
	return c:GetCode()>210300300 and c:GetCode()<210300400 and c:IsAbleToDeck() and c:IsType(TYPE_MONSTER)
end
function c210300308.rtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(c210300308.cfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
function c210300308.rop(e,tp,eg,ep,ev,re,r,rp)
	Duel.DisableShuffleCheck(true)
	local tg=Duel.SelectMatchingCard(tp,c210300308.cfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if Duel.IsExistingMatchingCard(c210300308.cfilter,tp,LOCATION_DECK,0,1,nil) then Duel.ShuffleDeck(tp) end
	Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
	Duel.DisableShuffleCheck(false)
end
function c210300308.tgtg(e,c)
	return c:GetCode()>210300300 and c:GetCode()<210300400 and c~=e:GetHandler()
end
function c210300308.indval(e,re,rp)
	return rp~=e:GetHandlerPlayer()
end
