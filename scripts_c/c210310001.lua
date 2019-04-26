--Icebox Elemelon Watermelon
--AlphaKretin
function c210310001.initial_effect(c)
	--negate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c210310001.disable)
	e1:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e1)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4031,2))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c210310001.destg)
	e2:SetOperation(c210310001.desop)
	c:RegisterEffect(e2)
	local ea=e2:Clone()
	ea:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(ea)
	local eb=e2:Clone()
	eb:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(eb)
	--search
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4031,0))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c210310001.thtg)
	e3:SetOperation(c210310001.thop)
	c:RegisterEffect(e3)
	--revive
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(210310001,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,210310001)
	e4:SetCondition(c210310001.spcon)
	e4:SetCost(c210310001.spcost)
	e4:SetTarget(c210310001.sptg)
	e4:SetOperation(c210310001.spop)
	c:RegisterEffect(e4)
end
function c210310001.disable(e,c)
local cg=e:GetHandler():GetColumnGroup()
	return (c:IsType(TYPE_EFFECT) or bit.band(c:GetOriginalType(),TYPE_EFFECT)==TYPE_EFFECT) and not c:IsAttribute(ATTRIBUTE_WATER) and cg:IsContains(c) and not c:IsControler(tp)
end
function c210310001.desfilter(c,attr)
	return c:IsSetCard(0xf31) and c:GetAttribute()~=attr and c:IsType(TYPE_MONSTER)
end
function c210310001.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(c210310001.desfilter,tp,LOCATION_DECK,0,1,c,c:GetAttribute()) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_DECK)
end
function c210310001.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,c210310001.desfilter,tp,LOCATION_DECK,0,1,1,c,c:GetAttribute())
	Duel.Destroy(g,REASON_EFFECT)
end
function c210310001.filter(c,e)
	return c:IsSetCard(0xf31) and c:IsDestructable(e) and c:IsType(TYPE_MONSTER)
end
function c210310001.thfilter(c)
	return c:IsSetCard(0xf31) and (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP))
end
function c210310001.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210310001.filter,tp,LOCATION_HAND,0,1,e:GetHandler(),e)
		and Duel.IsExistingMatchingCard(c210310001.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c210310001.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,c210310001.filter,tp,LOCATION_HAND,0,1,1,e:GetHandler(),e)
	if g:GetCount()>0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,c210310001.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
function c210310001.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
function c210310001.spcostfilter(c,attr)
	if not c:IsSetCard(0xf31) or c:IsAttribute(attr) or not c:IsAbleToRemoveAsCost() or not c:IsType(TYPE_MONSTER) then return false end
	if c:IsLocation(LOCATION_GRAVE) then
		return not Duel.IsPlayerAffectedByEffect(c:GetControler(),69832741)
	else
		return Duel.IsPlayerAffectedByEffect(c:GetControler(),69832741)
	end
end
function c210310001.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(c210310001.spcostfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,c,c:GetAttribute()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c210310001.spcostfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,c,c:GetAttribute())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c210310001.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c210310001.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
