--
--Chaos Space
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--Add to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Return to deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+100)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
function s.tgfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_DARK+ATTRIBUTE_LIGHT) and c:IsAbleToGraveAsCost()
		and Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil,c:GetAttribute())
end
function s.thfilter1(c,att)
	return c:IsAbleToHand() and c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_DARK+ATTRIBUTE_LIGHT)
		and c:IsLevelAbove(4) and c:IsLevelBelow(8) and not c:IsSummonableCard() and not c:IsAttribute(att)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	Duel.DiscardHand(tp,s.tgfilter,1,1,REASON_COST,tp)
	e:SetLabel(Duel.GetOperatedGroup():GetFirst():GetAttribute())
end
function s.thfilter2(c)
	return c:IsAttribute(ATTRIBUTE_DARK+ATTRIBUTE_LIGHT) and c:IsLevelAbove(4) and c:IsLevelBelow(8)
		and not c:IsSummonableCard() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g1=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
	if #g1>0 then
		Duel.SendtoHand(g1,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g1)
	end
end
function s.tdfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK+ATTRIBUTE_LIGHT) and c:IsAbleToDeck() and not c:IsSummonableCard()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_REMOVED,0,1,nil) and Duel.IsPlayerCanDiscardDeck(tp,1) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if tc and Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)==1 then
		Duel.BreakEffect()
		Duel.Draw(p,d,REASON_EFFECT)
	end
end