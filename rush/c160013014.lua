--賢帝家臣ツーゼ
--Zuse the Wisdom Vassal
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Gain LP
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e) return e:GetHandler():IsStatus(STATUS_SUMMON_TURN) end)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsDefense(1000) and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,2,nil) end
end
function s.setfilter(c,tp)
	return c:IsSpell() and c:IsSSetable(false, 1-tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,0,LOCATION_GRAVE,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,1-tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thfilter(c)
	return c:IsMonster() and c:IsDefense(1000) and c:IsLevelAbove(5) and c:IsAbleToHand()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	Duel.HintSelection(g,true)
	if not Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST) then return end
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(1-tp,s.setfilter,tp,0,LOCATION_GRAVE,1,1,nil,tp)
	if #g>0 then
		Duel.SSet(1-tp,g)
		if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g2=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
			if #g2>0 then
				Duel.HintSelection(g2,true)
				Duel.BreakEffect()
				Duel.SendtoHand(g2,nil,REASON_EFFECT)
			end
		end
	end
end