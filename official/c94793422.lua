--心眼の鉾
--Rod of the Mind's Eye
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--Change damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetValue(aux.ChangeBattleDamage(1,1000))
	c:RegisterEffect(e1)
end