--転生炎獣の炎奏
--Salamangreat Performance
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x119}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLP(tp)<Duel.GetLP(1-tp)
end
function s.tgfilter(c,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x119) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
function s.thfilter(c,code)
	return c:IsCode(code) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.tgfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tc:GetCode())
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end