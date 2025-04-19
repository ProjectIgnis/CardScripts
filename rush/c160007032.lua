-- シードラゴン・ナイト
-- Sea Dragon Knight
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Reveal
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.revcost)
	e1:SetTarget(s.revtg)
	e1:SetOperation(s.revop)
	c:RegisterEffect(e1)
end
function s.revcostfilter(c)
	return c:IsMonster() and c:IsAbleToDeckOrExtraAsCost()
end
function s.revcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.revcostfilter,tp,LOCATION_GRAVE,0,2,nil) end
end
function s.revtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_SZONE,1,nil) end
end
function s.revop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.revcostfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	Duel.HintSelection(g,true)
	if #g~=2 or Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)~=2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local tc=Duel.SelectMatchingCard(tp,Card.IsFacedown,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
	if not tc then return end
	Duel.ConfirmCards(tp,tc)
	if Duel.IsExistingMatchingCard(Card.IsCode,tp,0,LOCATION_GRAVE,1,nil,tc:GetCode())
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.BreakEffect()
		Duel.Destroy(tc,REASON_EFFECT)
	end
end