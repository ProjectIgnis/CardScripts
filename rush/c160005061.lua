--楽姫の独演
--Music Maiden's Solo Performance

local s,id=GetID()
function s.initial_effect(c)
	--Negate opponent monster's attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCountRush(Card.IsType,e:GetHandler():GetControler(),LOCATION_MZONE,0,nil,TYPE_MONSTER)==1
		and Duel.GetTurnPlayer()==1-tp and Duel.GetAttacker():IsLevelBelow(8)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.NegateAttack()
end