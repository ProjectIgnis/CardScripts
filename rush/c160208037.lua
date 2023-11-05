--大激虎
--Giant Tiger Strike
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Change opponent's attacking monster to defense position
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DAMAGE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	return at and at:IsCanChangePositionRush()
end
function s.filter(c)
	return c:IsMonster() and c:IsLevelAbove(7) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsAbleToHand() and c:IsFaceup() and not c:IsMaximumModeSide()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local at=Duel.GetAttacker()
	if chk==0 then return at:IsControler(1-tp) and at:IsAttackPos() and at:IsOnField() and at:IsCanChangePosition() end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,at,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.HintSelection(g,true)
	g=g:AddMaximumCheck()
	if Duel.SendtoHand(g,nil,REASON_EFFECT)<1 then return end
	--Effect
	local at=Duel.GetAttacker()
	if at and at:IsAttackPos() and at:IsRelateToBattle() and Duel.ChangePosition(at,POS_FACEUP_DEFENSE)>0 then
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	end
end