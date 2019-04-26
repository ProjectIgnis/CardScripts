--反発力
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetCode(EVENT_ATTACK_DISABLED)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local t=Duel.GetAttackTarget()
	return a:IsLocation(LOCATION_MZONE) and t and t:IsLocation(LOCATION_MZONE) and t:IsPosition(POS_FACEUP_ATTACK)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local a=Duel.GetAttacker()
	local t=Duel.GetAttackTarget()
	local g=Group.FromCards(a,t)
	local dam=math.abs(a:GetAttack()-t:GetAttack())
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(dam)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,1-tp,dam)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g<2 then return end
	local c1=g:GetFirst()
	local c2=g:GetNext()
	if c1:IsFaceup() and c2:IsFaceup() then
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		local dam=math.abs(c1:GetAttack()-c2:GetAttack())
		Duel.Damage(p,dam,REASON_EFFECT)
	end
end
