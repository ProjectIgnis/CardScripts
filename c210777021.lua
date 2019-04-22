--Aromatheraphy
--Scripted By Naim/Steelren
function c210777021.initial_effect(c)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetCountLimit(1,210777021)
	e1:SetCondition(c210777021.cond)
	e1:SetTarget(c210777021.target)
	e1:SetOperation(c210777021.activate)
	c:RegisterEffect(e1)
	--back to hand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_RECOVER)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,210777021+100)
	e2:SetCondition(c210777021.tohandcond)
	e2:SetTarget(c210777021.tohandtg)
	e2:SetOperation(c210777021.tohandoper)
	c:RegisterEffect(e2)
end
function c210777021.cond(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetLP(tp)>Duel.GetLP(1-tp)
end
function c210777021.filter(c)
	return c:IsAbleToHand() and c:IsSetCard(0xc9) and c:IsType(TYPE_MONSTER)
end
function c210777021.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
	return Duel.IsExistingMatchingCard(c210777021.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c210777021.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c210777021.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c210777021.filter2(c)
	return c:IsFaceup() and c:IsSetCard(0xc9)
end
function c210777021.tohandcond(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
	and Duel.IsExistingMatchingCard(c210777021.filter2,tp,LOCATION_MZONE,0,1,nil) and aux.exccon(e)
end
function c210777021.tohandtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function c210777021.tohandoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
