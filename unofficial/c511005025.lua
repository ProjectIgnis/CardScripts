--Bracer of Power
--scripted by Shad3, cleaned and updated up by MLD
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(500)
	c:RegisterEffect(e2)
end