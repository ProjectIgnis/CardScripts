--ジョインテック・ジョイント
--Jointech Joint
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Change Position and Fusion Summon
	local params={aux.FilterBoolFunction(s.fusfilter)}
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation(Fusion.SummonEffTG(table.unpack(params)),Fusion.SummonEffOP(table.unpack(params))))
	c:RegisterEffect(e1)
end
function s.fusfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH|ATTRIBUTE_DARK) and c:IsRace(RACE_MACHINE) and c:IsLevelBelow(9)
end
function s.cfilter(c)
	return c:IsMonster() and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,2,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanChangePositionRush,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,1-tp,0)
end
function s.operation(fustg,fusop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		--Requirement
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,2,2,nil)
		Duel.HintSelection(g,true)
		if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)<=0 then return end
		--Effect
		local g=Duel.SelectMatchingCard(tp,Card.IsCanChangePositionRush,tp,0,LOCATION_MZONE,1,1,nil)
		Duel.HintSelection(g,true)
		if g:GetFirst():IsAttackPos() then
			Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
		elseif g:GetFirst():IsFacedown() then
			Duel.ChangePosition(g,POS_FACEUP_ATTACK)
		else
			local op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
			if op==0 then
				Duel.ChangePosition(g,0,0,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
			else
				Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
			end
		end
		if fustg(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			fusop(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end