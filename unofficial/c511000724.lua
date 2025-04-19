--エクスプロージョン・ウィング
--Explosion Wing
--Rescripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Inflict 500 damage to your opponent for each card destroyed this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Count destructions
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local dg=eg:Filter(Card.IsReason,nil,REASON_EFFECT)
	if #dg==0 then return end
	for tc in dg:Iter() do
		Duel.RegisterFlagEffect(0,id,RESET_PHASE|PHASE_END,0,1)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetFlagEffect(0,id)
	if chk==0 then return ct>0 end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*500)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetFlagEffect(0,id)
	Duel.Damage(1-tp,ct*500,REASON_EFFECT)
end