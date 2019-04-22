--レアゴールド・アーマー
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--atk target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(s.atkcon)
	e2:SetValue(s.atktg)
	c:RegisterEffect(e2)
end
function s.atkcon(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:GetControler()==e:GetHandlerPlayer()
end
function s.atktg(e,c)
	return c~=e:GetHandler():GetEquipTarget()
end
