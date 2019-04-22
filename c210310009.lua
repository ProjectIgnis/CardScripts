--Doriado's Elemelon Farm
--AlphaKretin
function c210310009.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c210310009.activate)
	c:RegisterEffect(e1)
	--atk & def
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xf31))
	e2:SetValue(1000)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--destruction damage
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(c210310009.descon)
	e4:SetOperation(c210310009.desop)
	c:RegisterEffect(e4)
	--neg hand
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_NEGATE+CATEGORY_TOGRAVE)
	e5:SetType(EFFECT_TYPE_QUICK_F)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCode(EVENT_CHAINING)
	e5:SetCondition(c210310009.negcon)
	e5:SetTarget(c210310009.negtg)
	e5:SetOperation(c210310009.negop)
	c:RegisterEffect(e5)
	--neg gy/banish
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_CHAIN_SOLVING)
	e6:SetRange(LOCATION_FZONE)
	e6:SetCondition(c210310009.discon)
	e6:SetOperation(c210310009.disop)
	c:RegisterEffect(e6)
	--cannot set
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_CANNOT_SSET)
	e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e7:SetRange(LOCATION_FZONE)
	e7:SetTargetRange(0,1)
	e7:SetCondition(c210310009.setcon)
	e7:SetTarget(aux.TRUE)
	c:RegisterEffect(e7)
	--neg backrow
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e8:SetCode(EFFECT_CANNOT_ACTIVATE)
	e8:SetRange(LOCATION_FZONE)
	e8:SetTargetRange(1,0)
	e8:SetCondition(c210310009.acscon)
	e8:SetValue(c210310009.acslimit)
	c:RegisterEffect(e8)
end
function c210310009.filter(c)
	return c:IsSetCard(0xf31) and c:IsAbleToHand()
end
function c210310009.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(c210310009.filter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(4031,9)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function c210310009.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0xf31)
end
function c210310009.desfilter(c)
	return c:IsSetCard(0xf31) and c:IsType(TYPE_MONSTER) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
function c210310009.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c210310009.desfilter,1,nil)
		and Duel.IsExistingMatchingCard(c210310009.filter1,tp,LOCATION_MZONE,0,1,nil)
end
function c210310009.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Recover(tp,1000,REASON_EFFECT)
end
function c210310009.negcon(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return loc==LOCATION_HAND and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev) and not eg:GetFirst():IsControler(tp)
		and Duel.IsExistingMatchingCard(c210310009.filter1,tp,LOCATION_MZONE,0,2,nil)
end
function c210310009.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsAbleToGrave() end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,eg,1,0,0)
	end
end
function c210310009.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.SendtoGrave(eg,REASON_EFFECT)
	end
end
function c210310009.discon(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return re:IsActiveType(TYPE_MONSTER) and (loc==LOCATION_GRAVE or loc==LOCATION_REMOVED) and rp~=tp 
		and Duel.IsExistingMatchingCard(c210310009.filter1,tp,LOCATION_MZONE,0,3,nil)
end
function c210310009.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
function c210310009.setcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c210310009.filter1,tp,LOCATION_MZONE,0,4,nil)
end
function c210310009.acscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c210310009.filter1,tp,LOCATION_MZONE,0,5,nil)
end
function c210310009.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL)
end
