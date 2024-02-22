--エーテル・エスケープ
--Ether Escape
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsRace(RACE_WARRIOR|RACE_MACHINE) and c:IsMonster() and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,2,nil) end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if #eg~=1 then return false end
	local tc=eg:GetFirst()
	return tc:IsFaceup() and tc:IsLevelAbove(7) and tc:IsCanTurnSet() and tc:IsCanChangePositionRush() and tc:IsSummonPlayer(1-tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,eg:GetFirst(),1,0,0)
end
function s.thfilter(c)
	return c:IsFacedown() and c:IsAbleToDeck()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	Duel.HintSelection(g,true)
	if #g>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)>0 then
		--Effect
		local tc=eg:GetFirst()
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		if not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType,TYPE_FUSION),tp,LOCATION_MZONE,0,1,nil) then return end
		local g2=Duel.GetMatchingGroup(s.thfilter,tp,0,LOCATION_ONFIELD,nil)
		if #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local sg=g2:Select(tp,1,1,nil)
			Duel.HintSelection(sg,true)
			if #sg>0 then
				Duel.SendtoDeck(sg,nil,SEQ_DECKTOP,REASON_EFFECT)
			end
		end
	end
end