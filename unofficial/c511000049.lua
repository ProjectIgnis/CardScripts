--Central Shield
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,0)
	--Prevent Damage
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetValue(1)
	e3:SetTarget(s.dmtg)
	c:RegisterEffect(e3)
end
function s.dmtg(e,c)
	return c~=e:GetHandler():GetEquipTarget()
end