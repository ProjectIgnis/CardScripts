--Ｃ・コア
--Iron Chain Core
--Scripted by Eerie Code
function c120401029.initial_effect(c)
	--return to gy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(120401029,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,120401029)
	e1:SetCost(c120401029.gycost)
	e1:SetTarget(c120401029.gytg)
	e1:SetOperation(c120401029.gyop)
	c:RegisterEffect(e1)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(120401029,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCountLimit(1,120401029)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(c120401029.thcon)
	e2:SetTarget(c120401029.thtg)
	e2:SetOperation(c120401029.thop)
	c:RegisterEffect(e2)
end
function c120401029.gycost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function c120401029.gyfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x25) and c:IsType(TYPE_MONSTER)
end
function c120401029.gytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c120401029.gyfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c120401029.gyfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,c120401029.gyfilter,tp,LOCATION_REMOVED,0,1,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
function c120401029.gyop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=tg:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then 
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_RETURN)
	end
end
function c120401029.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
function c120401029.thfilter(c)
	return (c:IsCode(33302407,79707116,48276469,50078509,85893201) or c.is_chain) and c:IsAbleToHand()
end
function c120401029.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function c120401029.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c120401029.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
