--慈愛のアミュレット
--Amulet of Affection
local s,id=GetID()
function s.initial_effect(c)
	--Equip
	aux.AddEquipProcedure(c)
	--Take no battle damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end