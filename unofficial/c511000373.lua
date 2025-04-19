--モンスター回収 (Anime)
--Monster Recovery (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,5)
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND|LOCATION_MZONE,0,1,e:GetHandler()) end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND|LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,5)
end
function s.filter(c,p)
	return c:IsLocation(LOCATION_DECK) and c:IsControler(p)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_HAND|LOCATION_MZONE,0,nil)
	if #g==0 or Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then return end
	local og=Duel.GetOperatedGroup()
	if not og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK|LOCATION_EXTRA) then return end
	if og:IsExists(s.filter,1,nil,p) then Duel.ShuffleDeck(p) end
	Duel.BreakEffect()
	Duel.Draw(p,5,REASON_EFFECT)
end