--Handy Gallop
--scripted by andre
local s,id=GetID()
function s.initial_effect(c)
	--cannot attack direct
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	--gains attack
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	--battle damage change
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e3:SetCondition(s.damcondition)
	e3:SetOperation(s.damoperation)
	c:RegisterEffect(e3)
end
function s.atkval(e,c)
	return math.abs(Duel.GetLP(1)-Duel.GetLP(0))
end
function s.damcondition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and Duel.GetLP(tp)>Duel.GetLP(1-tp) and e:GetHandler()==Duel.GetAttacker()
end
function s.damoperation(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(tp,Duel.GetBattleDamage(1-tp),false)
	Duel.ChangeBattleDamage(1-tp,0)
end

