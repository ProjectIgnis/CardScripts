--深淵海竜アビス・クラーケン
--Abyssal Sea Dragon Abyss Kraken
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	Maximum.AddProcedure(c,nil,s.filter1,s.filter2)
	--actlimit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Cannot be destroyed
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.indcon)
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	c:AddCenterToSideEffectHandler(e2)
	c:AddMaximumAtkHandler()
end
s.MaximumAttack=4000
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsMaximumMode()
end
function s.filter1(c)
	return c:IsCode(160207016)
end
function s.filter2(c)
	return c:IsCode(160207018)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(s.aclimit)
	e1:SetCondition(s.actcon)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	Duel.RegisterEffect(e1,tp)
end
function s.aclimit(e,re,tp)
	return re:GetHandler():IsTrap() and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.actcon(e)
	return Duel.GetAttacker()==e:GetHandler()
end
function s.indcon(e)
	return not Duel.IsExistingMatchingCard(Card.IsMonster,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil)
end