--聖なるバリア －ミラーフォース－ (Anime)
--Mirror Force (Anime)
--Scripted by edo9300
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp)
end
function s.filter(c,atk)
	return c:GetAttack()<atk
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAttackPos,tp,0,LOCATION_MZONE,1,nil) end
	local dg=Duel.GetMatchingGroup(Card.IsAttackPos,tp,0,LOCATION_MZONE,nil)
	local a=Duel.GetAttacker()
	local atk=a:GetAttack()
	local g=dg:Filter(s.filter,a,a:GetAttack())
	local dam=0
	for tc in aux.Next(g) do
		dam=dam+(atk-tc:GetAttack())
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,#dg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local dg=Duel.GetMatchingGroup(Card.IsAttackPos,tp,0,LOCATION_MZONE,nil)
	if #dg>0 then
		local a=Duel.GetAttacker()
		local atk=a:GetAttack()
		local g=dg:Filter(s.filter,a,a:GetAttack())
		for tc in aux.Next(g) do
			Duel.HintSelection(Group.FromCards(tc))
			Duel.Damage(1-tp,atk-tc:GetAttack(),REASON_EFFECT,true)
		end
		Duel.RDComplete()
		Duel.Destroy(dg,REASON_EFFECT)
	end
end