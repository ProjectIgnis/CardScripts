--狂気の伝染
--Contagion of Madness
local s,id=GetID()
function s.initial_effect(c)
	--Activate when your opponent's monster declares an attack
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(function(e) return Duel.GetAttacker():IsControler(1-e:GetHandlerPlayer()) end)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Your opponent takes damage equal to half the battle damage you would take from this battle
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return ep==tp end)
	e1:SetOperation(function(e) Duel.Damage(1-e:GetHandlerPlayer(),Duel.GetBattleDamage(e:GetHandlerPlayer())/2,REASON_EFFECT) end)
	e1:SetReset(RESET_PHASE|PHASE_DAMAGE)
	Duel.RegisterEffect(e1,tp)
end
