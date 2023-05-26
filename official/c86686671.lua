--サイバー・リペア・プラント
--Cyber Repair Plant
local s,id=GetID()
function s.initial_effect(c)
	--Search 1 LIGHT <achine monster and/or Shuffle 1 LIGHT Machine monster into the Deck
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_CYBER_DRAGON}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,CARD_CYBER_DRAGON)
end
function s.thfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
function s.tdfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToDeck()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()~=0 then
			return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc)
		else return false end
	end
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	local b2=Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil)
	local b3=b1 and b2 and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,3,nil,CARD_CYBER_DRAGON)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)},
		{b3,aux.Stringid(id,2)})
	e:SetLabel(op)
	local cat=0
	if op&1>0 then
		cat=cat|CATEGORY_TOHAND+CATEGORY_SEARCH
		e:SetCategory(cat)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
	if op&2>0 then
		cat=cat|CATEGORY_TODECK
		e:SetCategory(cat)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,tp,0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local breakeff=false
	if op&1>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
		breakeff=true
	end
	if op&2>0 then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			if breakeff then Duel.BreakEffect() end
			Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end