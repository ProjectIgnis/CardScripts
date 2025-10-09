--超戦士の閃光
--Super Soldier Radiance
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
s.listed_names={5405694}
function s.filter1(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsLocation(LOCATION_MZONE)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter1,1,nil,tp)
end
function s.posfilter(c)
	return c:IsFaceup() and c:IsCode(5405694) and c:IsCanChangePositionRush()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeckOrExtraAsCost,tp,LOCATION_HAND,0,1,e:GetHandler()) 
		or Duel.IsExistingMatchingCard(s.posfilter,tp,LOCATION_MZONE,0,1,nil)
	end
end
function s.filter(c)
	return c:IsFaceup() and c:IsCanTurnSet() and c:IsCanChangePositionRush()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,tp,POS_FACEDOWN_DEFENSE)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(5405694)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	local b1=Duel.IsExistingMatchingCard(Card.IsAbleToDeckOrExtraAsCost,tp,LOCATION_HAND,0,1,e:GetHandler())
	local b2=Duel.IsExistingMatchingCard(s.posfilter,tp,LOCATION_MZONE,0,1,nil)
	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,1)},{b2,aux.Stringid(id,2)})
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local td=Duel.SelectMatchingCard(tp,Card.IsAbleToDeckOrExtraAsCost,tp,LOCATION_HAND,0,1,1,nil)
		if Duel.SendtoDeck(td,nil,SEQ_DECKBOTTOM,REASON_COST)<1 then return end
	elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
		local g=Duel.SelectMatchingCard(tp,s.posfilter,tp,LOCATION_MZONE,0,1,1,nil)
		if Duel.ChangePosition(g,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)<1 then return end
	end
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local ct=1
	if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) then ct=2 end
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_MZONE,1,ct,nil)
	if #g==0 then return end
	Duel.HintSelection(g)
	Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
end