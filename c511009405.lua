--Predaplant Cephalotus Snail
local s,id=GetID()
function s.initial_effect(c)
--damage reduce
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e1:SetCondition(s.rdcon)
	e1:SetOperation(s.rdop)
	c:RegisterEffect(e1)
	--battle indestructable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetCondition(s.con)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
function s.rdcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
function s.rdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(ep,ev/2)
end

function s.con(e,c)
	return e:GetHandler():IsAttackPos() 
end