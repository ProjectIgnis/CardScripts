--ピース・ドラゴン
--Peace Dragon
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Gain LP
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=10 and Duel.GetMatchingGroupCountRush(Card.IsSpell,tp,LOCATION_GRAVE,0,nil)==3
end
function s.tdfilter(c)
	return c:IsSpell() and c:IsAbleToDeckAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,3,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,PLAYER_ALL,1000)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil)
	Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_COST)
	Duel.SortDeckbottom(tp,tp,#g)
	--Effect
	Duel.Recover(tp,1000,REASON_EFFECT)
	Duel.Recover(1-tp,1000,REASON_EFFECT)
end