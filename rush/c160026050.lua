--ラワン冒険隊が行く！！
--The Lauan Adventurers Are Go!!
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Equip
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsAbleToDeckOrExtraAsCost()
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,c,tp)
end
function s.filter(c,tp)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil,c)
end
function s.eqfilter(c,tc)
	return c:IsRace(RACE_PLANT) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsType(TYPE_UNION)
		and c.eqeffect and c.equipfilter and c.equipfilter(tc)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler(),tp) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=0
	if e:GetHandler():IsLocation(LOCATION_HAND) then ct=1 end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>ct end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,c,tp)
	if Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_COST)<1 then return end
	--Effect
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local eqtg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_GRAVE,0,1,math.min(ft,2),nil,eqtg)
	for tc in g:Iter() do
		Duel.Equip(tp,tc,eqtg,true)
		tc.eqeffect(tc,eqtg)
	end
end