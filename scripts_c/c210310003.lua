--Pixie Elemelon Electlon
--AlphaKretin
function c210310003.initial_effect(c)
	--negate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c210310003.disable)
	e1:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e1)
	--extra summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xf31))
	c:RegisterEffect(e2)
	--destroy
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4031,5))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetTarget(c210310003.destg)
	e3:SetOperation(c210310003.desop)
	c:RegisterEffect(e3)
	--revive
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(4031,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,210310003)
	e4:SetCondition(c210310003.revcon)
	e4:SetCost(c210310003.revcost)
	e4:SetTarget(c210310003.revtg)
	e4:SetOperation(c210310003.revop)
	c:RegisterEffect(e4)
end
function c210310003.disable(e,c)
	local cg=e:GetHandler():GetColumnGroup()
	return (c:IsType(TYPE_EFFECT) or bit.band(c:GetOriginalType(),TYPE_EFFECT)==TYPE_EFFECT) and not c:IsAttribute(ATTRIBUTE_WIND) and cg:IsContains(c) and not c:IsControler(tp)
end
function c210310003.desfilter(c,attr)
	return c:IsSetCard(0xf31) and c:GetAttribute()~=attr
end
function c210310003.destgfilter(c,attr)
	local g1=Duel.GetMatchingGroup(c210310003.desfilter,tp,LOCATION_MZONE,0,nil,attr)
	local cg=c:GetColumnGroup()
	for gc in aux.Next(g1) do
		if cg:IsContains(gc) or c==gc then
			return true
		end
	end
	return false
end
function c210310003.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return Duel.IsExistingTarget(c210310003.destgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c:GetAttribute()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOHAND)
	local g=Duel.SelectTarget(tp,c210310003.destgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,c:GetAttribute())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c210310003.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if Duel.Destroy(e:GetHandler(),REASON_EFFECT) and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
function c210310003.revcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
function c210310003.revcostfilter(c,attr)
	if not c:IsSetCard(0xf31) or c:IsAttribute(attr) or not c:IsAbleToRemoveAsCost() or not c:IsType(TYPE_MONSTER) then return false end
	if c:IsLocation(LOCATION_GRAVE) then
		return not Duel.IsPlayerAffectedByEffect(c:GetControler(),69832741)
	else
		return Duel.IsPlayerAffectedByEffect(c:GetControler(),69832741)
	end
end
function c210310003.revcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(c210310003.revcostfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,c,c:GetAttribute()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c210310003.revcostfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,c,c:GetAttribute())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c210310003.revtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c210310003.revop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
