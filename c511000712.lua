--Greandier
local s,id=GetID()
function s.initial_effect(c)
	--damage monster
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLED)
	e1:SetDescription(aux.Stringid(10000020,1))
	e1:SetCondition(s.con)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler()==Duel.GetAttacker()
end
function s.chkfilter(c)
	return c:IsFaceup() and c:IsAttackBelow(500) and c:GetAttack()>0
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(s.chkfilter,tp,0,LOCATION_MZONE,Duel.GetAttackTarget())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,Duel.GetAttackTarget())
	local sg=Duel.GetMatchingGroup(s.chkfilter,tp,0,LOCATION_MZONE,Duel.GetAttackTarget())
	g:ForEach(function(tc)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end)
	sg=sg:Filter(Card.IsAttackBelow,nil,0)
	if #sg>0 then
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
