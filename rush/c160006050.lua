--ワイルド・キッチン
--Wild Kitchen
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.actcond)
	c:RegisterEffect(e1)
	--Decrease ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_FIRE))
	e2:SetValue(300)
	c:RegisterEffect(e2)
end
function s.actcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCountRush(aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_FIRE),e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)==3
end