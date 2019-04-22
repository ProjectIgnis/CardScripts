--Youkai Backup, Kamakura
function c210300306.initial_effect(c)
	aux.EnableDualAttribute(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25206027,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c210300306.spcon)
	e1:SetTarget(c210300306.sptg)
	e1:SetOperation(c210300306.spop)
	e1:SetCountLimit(1,210300306)
	c:RegisterEffect(e1)
	--on release
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetOperation(c210300306.checkop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_RELEASE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCondition(c210300306.rcon)
	e3:SetTarget(c210300306.rtg)
	e3:SetOperation(c210300306.rop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
function c210300306.spfilter(c,tp)
	return c:IsReason(REASON_DESTROY) and c:IsType(TYPE_DUAL) and c:IsType(TYPE_MONSTER)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousControler()==tp
end
function c210300306.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c210300306.spfilter,1,nil,tp)
end
function c210300306.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c210300306.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
function c210300306.checkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsDisabled() and c:IsDualState() and c:IsReason(REASON_RELEASE) then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
function c210300306.rcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()==1
end
function c210300306.cfilter1(c)
	return c:GetCode()>210300300 and c:GetCode()<210300400 and c:IsAbleToDeck() and c:IsType(TYPE_MONSTER)
		and Duel.IsExistingMatchingCard(c210300306.cfilter2,c:GetControler(),LOCATION_GRAVE,0,1,c,c)
end
function c210300306.cfilter2(c,cc)
	return c:GetCode()>210300300 and c:GetCode()<210300400 and c:IsAbleToDeck() and c:IsType(TYPE_MONSTER)
		and Duel.IsExistingMatchingCard(c210300306.cfilter3,c:GetControler(),LOCATION_GRAVE,0,1,Group.FromCards(c,cc),Group.FromCards(c,cc))
end
function c210300306.cfilter3(c,cg)
	cg:AddCard(c)
	return c:GetCode()>210300300 and c:GetCode()<210300400 and c:IsAbleToDeck() and c:IsType(TYPE_MONSTER)
		and Duel.IsExistingMatchingCard(c210300306.cfilter4,c:GetControler(),LOCATION_GRAVE,0,1,cg)
end
function c210300306.cfilter4(c)
	return c:GetCode()>210300300 and c:GetCode()<210300400 and c:IsAbleToDeck()
end
function c210300306.rtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(c210300306.cfilter1,tp,LOCATION_GRAVE,0,1,nil) end
end
function c210300306.rop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,c210300306.cfilter1,tp,LOCATION_GRAVE,0,3,3,nil)
	Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
	local sg=Duel.GetOperatedGroup()
	if sg:GetCount()==3 then
		if sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)>0 then Duel.ShuffleDeck(tp) Duel.DisableShuffleCheck(true) end
		Duel.BreakEffect()
		local tg=Duel.SelectMatchingCard(tp,c210300306.cfilter4,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
		Duel.DisableShuffleCheck(false)
	end
end
