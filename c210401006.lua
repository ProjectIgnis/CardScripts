--Survivor - Piranha
function c210401006.initial_effect(c)
	--atk up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xf18))
	e1:SetValue(c210401006.value)
	c:RegisterEffect(e1)
end
function c210401006.filter(c)
	return c:IsSetCard(0xf18) and c:IsType(TYPE_MONSTER)
end
function c210401006.value(e,c)
	local g=Duel.GetMatchingGroup(c210401006.filter,c:GetControler(),LOCATION_GRAVE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	return ct*100
end