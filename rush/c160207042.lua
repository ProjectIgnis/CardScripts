--アビス・フラッシュ
--Abyss Flash
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_GRAVE,0,5,nil,RACE_SEASERPENT)
end
function s.tdfilter(c)
	return c:IsMonster() and c:IsAbleToDeckAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsMonster,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return #g>0 and #g==g:FilterCount(Card.IsAbleToDeckAsCost,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanChangePositionRush,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,0,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil)
	if #g>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)==#g then
		--Effect
		local pg=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
		Duel.ChangePosition(pg,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
