--白鴉の騎士アイトワラス
--Aitvaras the White Crow Knight
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: 1 Illusion Tuner + 1+ non-Tuners
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_ILLUSION),1,1,Synchro.NonTuner(nil),1,99)
	--If this card is Special Summoned: You can target 1 card you control and 1 card your opponent controls; return them to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.rthtg)
	e1:SetOperation(s.rthop)
	c:RegisterEffect(e1)
	--If this card is sent to the GY: You can activate this effect based on where it was sent from;
	--● Field: Target 1 card on the field; shuffle it into the Deck
	--● Extra Deck: Special Summon 1 "White Crow" monster from your GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD|LOCATION_EXTRA)
	end)
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_WHITE_CROW}
function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetTargetGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,aux.dpcheck(Card.GetControler),0) end
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dpcheck(Card.GetControler),1,tp,HINTMSG_RTOHAND)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,2,tp,0)
end
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_WHITE_CROW) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local prev_loc=c:GetPreviousLocation()
	if chkc then return (e:GetChainData().previous_location&LOCATION_ONFIELD)>0 and chkc:IsOnField() and chkc:IsAbleToDeck() end
	if chk==0 then return ((prev_loc&LOCATION_ONFIELD)>0
		and Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil))
		or ((prev_loc&LOCATION_EXTRA)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)) end
	e:GetChainData().previous_location=prev_loc
	if (prev_loc&LOCATION_ONFIELD)>0 then
		--● Field: Target 1 card on the field; shuffle it into the Deck
		e:SetCategory(CATEGORY_TODECK)
		e:SetProperty(e:GetProperty()|EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,tp,0)
	elseif (prev_loc&LOCATION_EXTRA)>0 then
		--● Extra Deck: Special Summon 1 "White Crow" monster from your GY
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local prev_loc=e:GetChainData().previous_location
	if (prev_loc&LOCATION_ONFIELD)>0 then
		--● Field: Target 1 card on the field; shuffle it into the Deck
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	elseif (prev_loc&LOCATION_EXTRA)>0 then
		--● Extra Deck: Special Summon 1 "White Crow" monster from your GY
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end