--Impact Survivor - Mantis
function c210401004.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsRace,RACE_INSECT),aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_WATER))
	--self immune spell
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c210401004.efilter)
	c:RegisterEffect(e1)
	--grave immune spell
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xf18))
	e2:SetValue(c210401004.efilter)
	c:RegisterEffect(e2)
end
function c210401004.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL)
end
