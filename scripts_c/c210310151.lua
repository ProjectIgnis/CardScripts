--Frightfur Dragon
--AlphaKretin
function c210310151.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,c210310151.matfilter,2,2)
	c:EnableReviveLimit()
	--immune
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(c210310151.efilter)
	c:RegisterEffect(e1)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(61173621,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c210310151.thcon)
	e2:SetCost(c210310151.thcost)
	e2:SetTarget(c210310151.thtg)
	e2:SetOperation(c210310151.thop)
	c:RegisterEffect(e2)
	--reduce atk
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(aux.TRUE)
	e3:SetValue(c210310151.atkval)
	c:RegisterEffect(e3)
end
function c210310151.matfilter(c)
	return c:IsSetCard(0xa9) or c:IsSetCard(0xad) or c:IsSetCard(0xc3)
end
function c210310151.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
function c210310151.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function c210310151.cfilter(c)
	return c:IsSetCard(0xc3) and c:IsAbleToGraveAsCost()
end
function c210310151.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210310151.cfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c210310151.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,tp,REASON_COST)
end
function c210310151.thfilter(c)
	return (c:IsSetCard(0xad) or c:IsCode(24094653)) and c:IsAbleToHand()
end
function c210310151.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210310151.thfilter,tp,LOCATION_DECK,0,1,nil) and e:GetHandler():GetLinkedGroupCount()>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c210310151.thop(e,tp,eg,ep,ev,re,r,rp)
	local num=e:GetHandler():GetLinkedGroupCount()
	if not (num>0) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c210310151.thfilter,tp,LOCATION_DECK,0,1,num,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c210310151.atkfilter(c)
    return c:IsFaceup() and c:IsSetCard(0xad)
end
function c210310151.atkval(e,c)
    return e:GetHandler():GetLinkedGroup():FilterCount(c210310151.atkfilter,nil)*-400
end