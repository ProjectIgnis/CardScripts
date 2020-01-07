--Steel Armor
--Scripted by GameMaster(GM)
--updated by MLD
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--Def
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
end
