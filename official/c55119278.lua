--D・ラジオン
local s,id=GetID()
function s.initial_effect(c)
	--atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(s.cona)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x26))
	e1:SetValue(800)
	c:RegisterEffect(e1)
	--def
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetCondition(s.cond)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
end
s.listed_series={0x26}
function s.cona(e)
	return e:GetHandler():IsAttackPos()
end
function s.cond(e)
	return e:GetHandler():IsDefensePos()
end
