--Chain Reaction
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return aux.CanActivateSkill(tp)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Trap damage
	local e0=Effect.CreateEffect(e:GetHandler())
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(0x5f)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetOperation(aux.chainreg)
	Duel.RegisterEffect(e0,tp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(0x5f)
	e1:SetCondition(s.lpcon)
	e1:SetOperation(s.lpop)
	Duel.RegisterEffect(e1,tp)
end
function s.lpcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		and re:GetHandlerPlayer()==e:GetHandlerPlayer() and e:GetHandler():GetFlagEffect(1)>0
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.SetLP(1-e:GetHandlerPlayer(),Duel.GetLP(1-e:GetHandlerPlayer())-200)
end