--Flames of the Archfiend
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FIEND)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.filter(c)
	return c:IsFaceup() and not c:IsRace(RACE_FIEND)
end
function s.chkfilter(c)
	return s.filter(c) and c:IsAttackBelow(1000) and c:GetAttack()>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c1=Duel.GetFieldCard(0,LOCATION_SZONE,5)
	local c2=Duel.GetFieldCard(1,LOCATION_SZONE,5)
	if chk==0 then return true end
	local g=Group.CreateGroup()
	if c1 then g:AddCard(c1) end
	if c2 then g:AddCard(c2) end
	local sg=Duel.GetMatchingGroup(s.chkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	g:Merge(sg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,1000)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c1=Duel.GetFieldCard(0,LOCATION_SZONE,5)
	local c2=Duel.GetFieldCard(1,LOCATION_SZONE,5)
	local g=Group.CreateGroup()
	if c1 then g:AddCard(c1) end
	if c2 then g:AddCard(c2) end
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
	Duel.Damage(1-tp,1000,REASON_EFFECT,true)
	Duel.Damage(tp,1000,REASON_EFFECT,true)
	Duel.RDComplete()
	local sg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local sg2=Duel.GetMatchingGroup(s.chkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	sg:ForEach(function(tc)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end)
	sg2=sg2:Filter(Card.IsAttackBelow,nil,0)
	if #sg2>0 then
		Duel.Destroy(sg2,REASON_EFFECT)
	end
end
