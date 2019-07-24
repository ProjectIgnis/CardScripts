--Defense Paralysis
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHANGE_POS)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
	--Pos Change
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SET_POSITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsFaceup))
	e2:SetValue(POS_FACEUP_ATTACK)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsFacedown))
	e3:SetValue(POS_FACEDOWN_ATTACK)
	c:RegisterEffect(e3)
end
function s.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousPosition(POS_ATTACK) and c:IsPosition(POS_DEFENSE)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp)
end
