--尖頭狩猟ジャグール
--Headhunters' Jaguar
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	-- Shuffle monsters into the Deck
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
end
function s.tdfilter(c,slct)
	return c:IsMonster() and c:IsAbleToDeck() and (slct or c:IsType(TYPE_NORMAL))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,0,LOCATION_GRAVE,1,nil,false) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,1-tp,LOCATION_GRAVE)
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsType,1,nil,TYPE_NORMAL)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- Requirement
	if Duel.DiscardDeck(tp,1,REASON_COST)<1 then return end
	--Effect:
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,0,LOCATION_GRAVE,nil,true)
	if #g==0 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,2,s.rescon,1,tp,HINTMSG_TODECK)
	if #sg>0 then
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end