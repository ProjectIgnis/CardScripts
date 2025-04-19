--Kuribee
local s,id=GetID()
function s.initial_effect(c)
	--negate attack
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UNRELEASABLE_SUM)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_KURIBOH,44632120,71036835,7021574,34419588}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.GetAttackTarget()
	return d and d:IsControler(tp) and d:IsFaceup() and 
		(d:IsCode(44632120) or d:IsCode(71036835) or d:IsCode(7021574) or d:IsCode(34419588) or d:IsCode(CARD_KURIBOH))
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateAttack()
end