-- ヴィスカム・ナノトロン
--Viscom Nanotron
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Add cards to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
function s.excfilter(c)
	return not c:IsRace(RACE_CYBERSE) or not c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsMonster,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return #g==3 and not g:IsExists(s.excfilter,1,nil) and c:IsAbleToDeck() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,3,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsMonster,tp,LOCATION_GRAVE,0,nil)
	if #g==3 and not g:IsExists(s.excfilter,1,nil)
		and Duel.SendtoHand(g,tp,REASON_EFFECT)>0
		and c:IsRelateToEffect(e) and c:IsAbleToDeck() then
		Duel.BreakEffect()
		Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
