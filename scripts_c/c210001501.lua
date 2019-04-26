--Istrakan Maiden - Lita
function c210001501.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(c210001501.spcon)
	e1:SetRange(LOCATION_HAND)
	c:RegisterEffect(e1)
	--normal summoned
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,210001500)
	e2:SetTarget(c210001501.thtg)
	e2:SetOperation(c210001501.thop)
	c:RegisterEffect(e2)
	--banish
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,210001501)
	e3:SetCondition(aux.exccon)
	e3:SetCost(c210001501.cost)
	e3:SetTarget(c210001501.target)
	e3:SetOperation(c210001501.operation)
	c:RegisterEffect(e3)
end
function c210001501.spf(c)
	return c:IsFaceup() and c:IsSetCard(0x1f69)
end
function c210001501.spcon(e,c)
	if c==nil then return true end
	return Duel.IsExistingMatchingCard(c210001501.spf,c:GetControler(),LOCATION_MZONE,0,1,nil)
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function c210001501.thf(c)
	return c:IsCode(210001512) --or c:IsSetCard(???) "Solar Gun Lens - Luna" card
end
function c210001501.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210001501.thf,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c210001501.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c210001501.thf,tp,LOCATION_DECK,0,1,1,nil)
	if g and #g>0 then
		Duel.SendtoHand(g,tp,REASON_EFFECT)
	end
end
function c210001501.sff(c,m)
	return c:IsSetCard(0xf71) and ((m==1 and c:IsAbleToHand()) or (m==0 and c:IsAbleToRemoveAsCost()))
end
function c210001501.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,69832741)
		and c:IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(c210001501.sff,tp,LOCATION_GRAVE,0,1,c,0) end
	local g=Duel.SelectMatchingCard(tp,c210001501.sff,tp,LOCATION_GRAVE,0,1,1,c,0)
	g=g+c
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c210001501.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210001501.sff,tp,LOCATION_DECK,0,1,nil,1) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c210001501.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c210001501.sff,tp,LOCATION_DECK,0,1,1,nil,1)
	if g and #g>0 then
		Duel.SendtoHand(g,tp,REASON_EFFECT)
	end
end