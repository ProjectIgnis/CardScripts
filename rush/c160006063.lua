-- バトル左遷
-- Battle Demotion

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
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,600) end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttackTarget() 
	return tc and tc:IsFaceup() and tc:IsControler(tp) and tc:IsRace(RACE_MACHINE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--requirement
	Duel.PayLPCost(tp,600)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectMatchingCard(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
	end
end
function s.posfilter(c)
	return c:IsAttackPos() and c:IsCanChangePositionRush()
end
