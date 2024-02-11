--キングス・グリード
--King's Greed
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Position change
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter1(c)
	return c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevelAbove(5) and c:IsAbleToGraveAsCost()
end
function s.cfilter2(c)
	return c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevelAbove(7) and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_HAND,0,1,nil) or Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_GRAVE,0,3,nil) end
end
function s.filter(c)
	return c:IsAttackPos() and c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsCanChangePositionRush()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	local b1=Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_HAND,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_GRAVE,0,3,nil)
	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,1)},{b2,aux.Stringid(id,2)})
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local dg=Duel.SelectMatchingCard(tp,s.cfilter1,tp,LOCATION_HAND,0,1,1,nil)
		if Duel.SendtoGrave(dg,REASON_COST)==0 then return end
	elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_GRAVE,0,3,3,nil)
		Duel.HintSelection(g,true)
		if Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_COST)==0 then return end
		Duel.ShuffleDeck(tp)
	end
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g,true)
		if Duel.ChangePosition(g,POS_FACEUP_DEFENSE)>0 and Duel.IsPlayerCanDraw(tp,2) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.Draw(tp,2,REASON_EFFECT)
		end
	end
end