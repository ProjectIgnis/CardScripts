--ＡＬＥＲＴ！
--ALERT!
--Scripted by Zefile
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_RESCUE_ACE}
s.listed_names={CARD_R_ACE_HYDRANT}
function s.thfilter(c)
	return c:IsSetCard(SET_RESCUE_ACE) and c:IsMonster() and c:IsAbleToHand()
end
function s.hydrant_chk(tp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_R_ACE_HYDRANT),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=LOCATION_GRAVE
	if s.hydrant_chk(tp) then loc=loc|LOCATION_DECK end
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,loc,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE|LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local loc=LOCATION_GRAVE
	if s.hydrant_chk(tp) then loc=loc|LOCATION_DECK end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,loc,0,1,1,nil)
	if #g>0 then 
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end