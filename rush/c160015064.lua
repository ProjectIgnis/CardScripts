--蒼救の願い
--Skysavior Wish
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(function(e,tp,eg) return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp) end)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_FUSION,160012053}
function s.cfilter(c)
	return (c:IsRace(RACE_FAIRY) or (c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_WATER))) and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
		return aux.SelectUnselectGroup(g,e,tp,2,2,aux.dpcheck(Card.GetRace),0)
	end
end
function s.tdfilter(c)
	return c:IsAbleToDeck() and not c:IsMaximumModeSide()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_MZONE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end
function s.setfilter(c)
	return c:IsCode(CARD_FUSION,160012053) and c:IsSSetable()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	local rqg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dpcheck(Card.GetRace),1,tp,HINTMSG_TODECK)
	if #rqg==0 then return end
	Duel.HintSelection(rqg)
	if Duel.SendtoDeck(rqg,nil,SEQ_DECKTOP,REASON_COST)==0 then return end
	local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_DECK)
	if #og>0 then Duel.SortDecktop(tp,tp,#og) end
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local dg=Duel.SelectMatchingCard(tp,s.tdfilter,tp,0,LOCATION_MZONE,1,1,nil)
	if #dg==0 then return end
	dg=dg:AddMaximumCheck()
	Duel.HintSelection(dg)
	if Duel.SendtoDeck(dg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)==0 then return end
	if #dg>1 then
		Duel.SortDeckbottom(1-tp,1-tp,#dg)
	end
	local stg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.setfilter),tp,LOCATION_GRAVE,0,nil)
	if #stg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local sg=stg:Select(tp,1,1,nil)
		Duel.BreakEffect()
		Duel.SSet(tp,sg)
	end
end
