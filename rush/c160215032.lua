--双焔魔天ルナエル
--Twin Blaze Fiend Angel Lunael
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Ritual
	c:EnableReviveLimit()
	--Monsters on your opponent's field lose 1000 ATK/DEF
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(s.condition)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsFaceup))
	e1:SetValue(-1000)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--actlimit
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.condition2)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
function s.filter(c)
	return c:IsFaceup() and c:IsLevel(10) and c:IsAttribute(ATTRIBUTE_FIRE)
end
function s.condition(e)
	return Duel.IsExistingMatchingCard(s.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
function s.condition2(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MAXIMUM)>2
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(s.aclimit)
	e1:SetCondition(s.actcon)
	e1:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(e1,tp)
end
function s.aclimit(e,re,tp)
	return re:GetHandler():IsTrap() and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.actcon(e)
	local c=Duel.GetAttacker()
	return c:IsLevel(10) and c:IsAttribute(ATTRIBUTE_FIRE)
end