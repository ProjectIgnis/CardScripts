--ブラック・ハンドシェイカー
--Black Handshaker
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Shuffle to Deck
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,nil) end
end
function s.filter(c)
	return c:IsAttackPos() and c:IsCanChangePositionRush()
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsLevelAbove(7)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,1,nil)
	if #g==0 or Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then return end
	if not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) then return end
	local sg=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
		local sc=Group.Select(sg,tp,1,1,nil)
		if #sc==0 then return end
		Duel.HintSelection(sc,true)
		Duel.BreakEffect()
		Duel.ChangePosition(sc,POS_FACEUP_DEFENSE)
	end
end