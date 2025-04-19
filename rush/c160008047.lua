-- 花牙紫吹
--Shadow Flower Flurry
local s,id=GetID()
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.costfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsFaceup() and c:IsAbleToGraveAsCost()
		and Duel.IsExistingMatchingCard(aux.AND(Card.IsDefensePos,Card.IsCanChangePosition),0,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if #g==0 then return end
	g=g:AddMaximumCheck()
	if Duel.SendtoGrave(g,REASON_COST)==0 then return end
	-- Effect
	local tc=Duel.SelectMatchingCard(tp,aux.AND(Card.IsDefensePos,Card.IsCanChangePosition),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
	if tc and Duel.ChangePosition(tc,0,0,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)>0 and Duel.IsPlayerCanDraw(tp,1)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end