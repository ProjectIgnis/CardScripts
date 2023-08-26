--スカイポーター・マックス
--Skyporter Max
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Place 2/3 Maximum Monsters on top of the Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.tdcostfilter(c)
	return c:IsMonster() and c:IsAbleToDeckOrExtraAsCost()
end
function s.tdfilter(c,tp)
	return c:IsMonster() and c:IsType(TYPE_MAXIMUM) and c:IsAbleToDeck()
		and Duel.IsExistingMatchingCard(s.tdfilter2,tp,LOCATION_GRAVE,0,1,c,tp,c)
end
function s.tdfilter2(c,tp,tc)
	local g=Group.CreateGroup()
	g:AddCard(c)
	g:AddCard(tc)
	return c:IsMonster() and c:IsType(TYPE_MAXIMUM) and c:IsAbleToDeck()
		and Duel.IsExistingMatchingCard(s.tdcostfilter,tp,LOCATION_GRAVE,0,10,g)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter3,tp,LOCATION_GRAVE,0,2,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,0,0)
end
function s.tdfilter3(c)
	return c:IsMonster() and c:IsType(TYPE_MAXIMUM) and c:IsAbleToDeck()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	local g=Duel.GetMatchingGroup(s.tdcostfilter,tp,LOCATION_GRAVE,0,nil)
	local pg=Duel.GetMatchingGroup(s.tdfilter3,tp,LOCATION_GRAVE,0,nil)
	if #g<10 or #pg<2 then return end
	local td=aux.SelectUnselectGroup(g,e,tp,10,10,s.rescon(pg),1,tp,HINTMSG_TODECK)
	Duel.HintSelection(td,true)
	if Duel.SendtoDeck(td,nil,SEQ_DECKSHUFFLE,REASON_COST)>0 then
		Duel.ShuffleDeck(tp)
		local tg=Duel.SelectMatchingCard(tp,s.tdfilter3,tp,LOCATION_GRAVE,0,2,3,nil)
		Duel.HintSelection(tg,true)
		Duel.SendtoDeck(tg,nil,SEQ_DECKTOP,REASON_EFFECT)
		Duel.SortDecktop(tp,tp,#tg)
	end
end
function s.rescon(pg)
	return function(sg,e,tp,mg)
		local check=pg:IsExists(aux.TRUE,2,sg)
		return check,not check
	end
end