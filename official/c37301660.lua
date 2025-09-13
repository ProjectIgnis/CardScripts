--Japanese name
--WINDS OF VICTORY
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--The equipped monster gains 300 ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(300)
	c:RegisterEffect(e1)
	--Also it becomes WIND
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e2:SetValue(ATTRIBUTE_WIND)
	c:RegisterEffect(e2)
end