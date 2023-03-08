--降格処分
--Demotion
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--Decrease the equipped monster's Level by 2
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(-2)
	c:RegisterEffect(e1)
end