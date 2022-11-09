--Titan Showdown
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,2,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.flipop)
	c:RegisterEffect(e1)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	--Double damage to you
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetRange(0x5f)
	e1:SetCondition(s.damcon1)
	e1:SetValue(aux.ChangeBattleDamage(0,DOUBLE_DAMAGE))
	Duel.RegisterEffect(e1,tp)
	--Double damage to your opponent
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetRange(0x5f)
	e2:SetCondition(s.damcon2)
	e2:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	Duel.RegisterEffect(e2,tp)
end
function s.damcon1(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetLP(tp)>=(Duel.GetLP(1-tp)*2)
end
function s.damcon2(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetLP(1-tp)>=(Duel.GetLP(tp)*2)
end
