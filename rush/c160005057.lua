-- 花牙踏み
--Shadow Flower Stance

local s,id=GetID()
function s.initial_effect(c)
	--change pos
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttackTarget()
	return tc and tc:IsFaceup() and tc:IsControler(tp) and tc:IsRace(RACE_PLANT) and Duel.GetAttacker():IsCanChangePositionRush()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,2,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg=Duel.GetAttackTarget()
	if chk==0 then return tg:IsControler(tp) and tg:IsOnField() end
end
function s.tdfilter(c)
	return c:IsMonster() and c:IsRace(RACE_PLANT) and c:IsAbleToDeckOrExtraAsCost()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	local td=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	Duel.HintSelection(td)
	if Duel.SendtoDeck(td,nil,SEQ_DECKBOTTOM,REASON_COST)~0 then
		Duel.SortDeckbottom(tp,tp,2)
		
		local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
		if #g>0 then
			Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
		end
		
	end
end
function s.posfilter(c)
	return c:IsAttackPos() and c:IsCanChangePositionRush()
end
