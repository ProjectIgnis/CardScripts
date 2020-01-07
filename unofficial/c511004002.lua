--Mirror Force (anime)
--Scripted by edo9300
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return tp~=Duel.GetTurnPlayer()
end
function s.filter(c,atk)
	return c:IsAttackPos() and c:GetAttack()<=atk
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil,Duel.GetAttacker():GetAttack()) end
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil,Duel.GetAttacker():GetAttack())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil,Duel.GetAttacker():GetAttack())
	local a=Duel.GetAttacker()
	g:RemoveCard(a)
	if #g>0 then
		local tc=g:GetFirst()
		while tc do
			Duel.HintSelection(Group.FromCards(tc))
			Duel.Damage(1-tp,a:GetAttack()-tc:GetAttack(),REASON_EFFECT)
			Duel.Destroy(tc,REASON_EFFECT)
			tc=g:GetNext()
		end
	end
	Duel.Destroy(a,REASON_EFFECT)
end
