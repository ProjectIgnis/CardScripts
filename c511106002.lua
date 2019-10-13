--ハイドライブ・ユーティリゼーション
--Hydradrive Utilization (Anime)
--scripted by Hatter

local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
 	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x577}
function s.filter(c,e,tp)
	return c:IsSetCard(0x577) and c:IsAbleToRemove() and c:IsType(TYPE_MONSTER) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
function s.thfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsAbleToHand()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	Duel.PayLPCost(tp,500)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc,e,tp) end
	if chk==0 then return 
	Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then 
	if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,tc:GetCode()) then
	 	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOHAND)
	 	local tg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetCode())
	 	if #tg>0 then
	 	Duel.SendtoHand(tg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tg) end
		end
	end
end
