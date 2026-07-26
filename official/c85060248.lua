--メンタルプロテクター
--Mind Protector
local s,id=GetID()
function s.initial_effect(c)
	--Monsters with 2000 or less ATK cannot declare an attack, except for Psychic monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.atktarget)
	c:RegisterEffect(e1)
	--This card's controller must pay 500 LP during each of their Standby Phases. If they cannot, destroy this card
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.mtcon)
	e2:SetOperation(s.mtop)
	c:RegisterEffect(e2)
end
function s.atktarget(e,c)
	return not c:IsRace(RACE_PSYCHIC) and c:IsAttackBelow(2000)
end
function s.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp)
end
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.CheckLPCost(tp,500) then
		Duel.PayLPCost(tp,500)
	else
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end