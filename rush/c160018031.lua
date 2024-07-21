--叛骨のガイガスト
--Guyghast the Defiant Soul
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Destroy 1 monster the opponent controls
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
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
	return Duel.GetMatchingGroupCount(Card.IsMonster,tp,LOCATION_GRAVE,0,nil)>=5
end
function s.costfilter(c)
	return c:IsMonster() and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsLevelBelow,8),tp,0,LOCATION_MZONE,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	if Duel.SendtoGrave(g,REASON_COST)==0 then return end
	--Effect
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsLevelBelow,8),tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		local c=e:GetHandler()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=g:Select(tp,1,1,nil)
		dg:AddMaximumCheck()
		Duel.HintSelection(dg)
		Duel.Destroy(dg,REASON_EFFECT)
	end
	local c=e:GetHandler()
	--Cannot be tributed for a tribute summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(3304)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetValue(1)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	c:RegisterEffect(e1)
end