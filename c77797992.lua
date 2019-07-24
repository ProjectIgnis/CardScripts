--森の聖獣 アルパカリブ
local s,id=GetID()
function s.initial_effect(c)
	--indes1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(s.cona)
	e1:SetTarget(s.targeta)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--cannot be target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.cond)
	e2:SetTarget(s.targetd)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
function s.cona(e)
	return e:GetHandler():IsAttackPos()
end
function s.targeta(e,c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsRace(RACE_WINGEDBEAST+RACE_PLANT+RACE_INSECT)
end
function s.cond(e)
	return e:GetHandler():IsDefensePos()
end
function s.targetd(e,c)
	return c:IsPosition(POS_FACEUP_DEFENSE) and c:IsRace(RACE_WINGEDBEAST+RACE_PLANT+RACE_INSECT)
end
