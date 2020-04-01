--D・ボードン
local s,id=GetID()
function s.initial_effect(c)
	--atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(s.cona)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x26))
	c:RegisterEffect(e1)
	--def
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetCondition(s.cond)
	e2:SetTarget(s.tgd)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
s.listed_series={0x26}
function s.cona(e)
	return e:GetHandler():IsAttackPos()
end
function s.cond(e)
	return e:GetHandler():IsDefensePos()
end
function s.tgd(e,c)
	return c:IsSetCard(0x26) and c~=e:GetHandler()
end
