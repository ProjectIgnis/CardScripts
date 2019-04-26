--Crimson Elemelon Flamelon
--AlphaKretin
function c210310000.initial_effect(c)
	--negate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c210310000.disable)
	e1:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e1)
	--multi attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetValue(c210310000.raval)
	c:RegisterEffect(e2)
	--search
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4031,1))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c210310000.thtg)
	e3:SetOperation(c210310000.thop)
	c:RegisterEffect(e3)
	--revive
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(4031,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,210310000)
	e4:SetCondition(c210310000.spcon)
	e4:SetCost(c210310000.spcost)
	e4:SetTarget(c210310000.sptg)
	e4:SetOperation(c210310000.spop)
	c:RegisterEffect(e4)
end
function c210310000.disable(e,c)
	local cg=e:GetHandler():GetColumnGroup()
	return (c:IsType(TYPE_EFFECT) or bit.band(c:GetOriginalType(),TYPE_EFFECT)==TYPE_EFFECT) and not c:IsAttribute(ATTRIBUTE_FIRE) and cg:IsContains(c) and not c:IsControler(tp)
end
function c210310000.raval(e,c)
	local tp=e:GetHandlerPlayer()
	local att=0
	for i=0,4 do
		local tc=Duel.GetFieldCard(tp,LOCATION_MZONE,i)
		if tc and tc:IsFaceup() and c~=tc then att=bit.bor(att,tc:GetAttribute()) end
	end
	local ct=0
	while att~=0 do
		if bit.band(att,0x1)~=0 then ct=ct+1 end
		att=bit.rshift(att,1)
	end
	return ct-1
end
function c210310000.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0xf31) and c:IsDestructable(e) and Duel.IsExistingMatchingCard(c210310000.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetAttribute())
end
function c210310000.thfilter(c,e,tp,attr)
	return c:IsSetCard(0xf31) and not c:IsAttribute(attr) and c:IsAbleToHand() and c:IsType(TYPE_MONSTER)
end
function c210310000.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c210310000.filter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(c210310000.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c210310000.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,c210310000.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=Duel.SelectMatchingCard(tp,c210310000.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetAttribute())
		if sg:GetCount()>0 then
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
function c210310000.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
function c210310000.spcostfilter(c,attr)
	if not c:IsSetCard(0xf31) or c:IsAttribute(attr) or not c:IsAbleToRemoveAsCost() or not c:IsType(TYPE_MONSTER) then return false end
	if c:IsLocation(LOCATION_GRAVE) then
		return not Duel.IsPlayerAffectedByEffect(c:GetControler(),69832741)
	else
		return Duel.IsPlayerAffectedByEffect(c:GetControler(),69832741)
	end
end
function c210310000.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(c210310000.spcostfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,c,c:GetAttribute()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c210310000.spcostfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,c,c:GetAttribute())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c210310000.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c210310000.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
