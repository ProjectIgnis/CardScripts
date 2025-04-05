--メタルシルバー・アーマー
--Metalsilver Armor
local LOC_MZN_GRV_BAN=LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--Limit effect target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOC_MZN_GRV_BAN,LOC_MZN_GRV_BAN)
	e1:SetCondition(s.cond)
	e1:SetTarget(s.efftg)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
end
function s.cond(e)
	local tc=e:GetHandler():GetEquipTarget()
	return tc and tc:GetControler()==e:GetHandler():GetControler()
end
function s.efftg(e,c)
	return c~=e:GetHandler():GetEquipTarget() and c:IsMonster()
		and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED))--face-down banished cards can still be targeted
end