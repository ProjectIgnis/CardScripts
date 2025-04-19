--エン・ムーン
--En Moon
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
	--Fusion monsters that banished or on the field/in the GYS become Normal monsters and their effects are negated
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED,LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsOriginalType,TYPE_FUSION))
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CHANGE_TYPE)
	e3:SetValue(TYPE_NORMAL)
	c:RegisterEffect(e3)
end
s.listed_names={511009535}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,511009535),tp,LOCATION_STZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,3,nil,TYPE_FUSION)
end