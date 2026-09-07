--翼の魔獣ガルヴァス
--Garvas the Winged Magical Beast
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_BEAST))
	e1:SetValue(s.value)
	c:RegisterEffect(e1)
	--Atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsCode,33951077))
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
s.listed_names={33951077}
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST) and not c:IsType(TYPE_EFFECT)
end
function s.value(e,c)
	return Duel.GetMatchingGroupCount(s.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)*500
end