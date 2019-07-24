--Telescopic Lens
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--Atk up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.value)
	c:RegisterEffect(e2)
end
function s.value(e,c)
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND,0)*400
end
