--降格処分
--Demotion
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,s.filter)
	--lvl
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_LEVEL)
	e2:SetValue(-2)
	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:HasLevel()
end
