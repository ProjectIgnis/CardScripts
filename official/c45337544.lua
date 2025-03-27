--ヒロイック・エンヴォイ
--Heroic Envoy
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Search 1 "Heroic" monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.dthtg)
	e1:SetOperation(s.dthop)
	c:RegisterEffect(e1)
	--Add 1 "Heroic" card from the GY to the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(_,tp) return Duel.GetLP(tp)<=500 end)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.gthtg)
	e2:SetOperation(s.gthop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_HEROIC}
function s.thfilter(c)
	return c:IsSetCard(SET_HEROIC) and c:IsAbleToHand()
end
function s.dthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.AND(s.thfilter,Card.IsMonster),tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.dthop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.AND(s.thfilter,Card.IsMonster),tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.gthtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_GRAVE)
end
function s.gthop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,tc)
	end
end