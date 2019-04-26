--ティアラ・フィナーレ
--Tiara Finale
--Scripted by Eerie Code
function c120401038.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c120401038.condition)
	e1:SetTarget(c120401038.target)
	e1:SetOperation(c120401038.activate)
	c:RegisterEffect(e1)
	--act in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e2:SetCondition(c120401038.handcon)
	c:RegisterEffect(e2)
end
function c120401038,hcfilter(c)
	return c:IsFaceup() and c:IsCode(37164373)
end
function c120401038.handcon(e)
	return Duel.IsExistingMatchingCard(c120401038.hcfilter,e:GetHandler():GetControler(),LOCATION_MZONE,0,1,nil)
end
function c120401038.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x71)
end
function c120401038.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c120401038.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c120401038.puddingfilter(c)
	return c:IsFaceup() and (c:IsCode(74641045,44311445) or c.is_pudding)
end
function c120401038.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,0,0)
end
function c120401038.thfilter(c)
	return c:IsSetCard(0x71) and c:IsAbleToHand()
end
function c120401038.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tc=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil):GetFirst()
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c120401038.thfilter),tp,LOCATION_GRAVE,0,nil)
	if tc and Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) 
		and Duel.IsExistingMatchingCard(c120401038.puddingfilter,tp,LOCATION_MZONE,0,1,nil) 
		and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(120401038,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
