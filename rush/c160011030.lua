--暗黒の熾天使
--Seraph of Darkness
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Change the position of an opponent's monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevelAbove(5) and c:IsFaceup()
end
function s.posfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(8) and c:IsCanChangePositionRush()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,500) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,1-tp,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.PayLPCost(tp,500)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectMatchingCard(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.ChangeToFaceupAttackOrFacedownDefense(g:GetFirst(),tp)
	end
end