--Sharkify
--Scripted by Snrk
--updated by MLD
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--Shark
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_ADD_SETCODE)
	e2:SetValue(0x547)
	c:RegisterEffect(e2)
	--Atk up
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(300)
	c:RegisterEffect(e3)
end
