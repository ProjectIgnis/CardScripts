--放課後に聞こえるピアノの音
--The Sound of Piano Heard After School
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Atk up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTarget(s.tg)
	e1:SetValue(500)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.tg)
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
end
function s.tg(e,c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK) and (c:GetBaseAttack()==0 or c:GetBaseDefense()==0)
end