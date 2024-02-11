--暴風輪
--Ring of Storms
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsMonster() and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,2,nil) end
end
function s.tdfilter(c,tp)
	return c:IsAbleToDeck() and c:IsMonster() and Duel.IsExistingMatchingCard(s.tdfilter2,tp,0,LOCATION_GRAVE,1,c,c:GetCode())
end
function s.tdfilter2(c,code)
	return c:IsAbleToDeck() and c:IsMonster() and not c:IsCode(code)
end
function s.tdfilter3(c)
	return c:IsMonster() and c:IsAbleToDeck()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,0,LOCATION_GRAVE,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_GRAVE)
end
function s.shufflefilter(c)
	return c:IsFaceup() and c:IsLevelBelow(8) and c:IsAbleToDeck()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	Duel.HintSelection(g,true)
	if #g==0 or Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)==0 then return end
	-- Effect
	local dg=Duel.GetMatchingGroup(s.tdfilter3,tp,0,LOCATION_GRAVE,nil)
	local sg=aux.SelectUnselectGroup(dg,e,tp,2,7,aux.dncheck,1,tp,HINTMSG_TODECK)
	if #sg==0 then return end
	Duel.HintSelection(sg,true)
	if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>=6
		and Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.shufflefilter),tp,0,LOCATION_MZONE,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g2=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.shufflefilter),tp,0,LOCATION_MZONE,1,1,nil)
		if #g2>0 then
			Duel.HintSelection(g2,true)
			Duel.SendtoDeck(g2,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end