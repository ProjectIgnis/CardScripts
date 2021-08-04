--天空の歌声
--Chorus in the Sky
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_SANCTUARY_SKY}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function s.thfilter1(c)
	return c:IsRace(RACE_FAIRY) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:isControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.thfilter1(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter1,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter1,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thfilter2(c)
	return c:IsFaceup() and (c:IsCode(CARD_SANCTUARY_SKY) or aux.IsCodeListed(c,CARD_SANCTUARY_SKY)) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_HAND) and (Duel.IsEnvironment(CARD_SANCTUARY_SKY) 
		or Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,CARD_SANCTUARY_SKY),0,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil))
		and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_REMOVED,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_REMOVED,0,1,1,nil)
		if #g>0 then
			Duel.BreakEffect()
			Duel.HintSelection(g,true)
			Duel.SendtoHand(g,nil,REASON_EFFECT)
		end
	end
end