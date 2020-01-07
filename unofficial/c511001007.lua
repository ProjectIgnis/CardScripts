--Defense Wall
local s,id=GetID()
function s.initial_effect(c)
	--target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetCondition(s.con)
	e1:SetTarget(s.tglimit)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
function s.con(e)
	return e:GetHandler():IsDefensePos()
end
function s.tglimit(e,c)
	return c~=e:GetHandler()
end