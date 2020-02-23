--断層地帯 (Action Field)
--Canyon (Action Field)
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--damage amp
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e2:SetCondition(s.dcon)
	e2:SetOperation(s.dop)
	c:RegisterEffect(e2)
end
s.af="a"
function s.dcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst():IsDefensePos() and eg:GetFirst():IsRace(RACE_ROCK)
end
function s.dop(e,tp,eg,ep,ev,re,r,rp)
	Duel.DoubleBattleDamage(ep)
end
