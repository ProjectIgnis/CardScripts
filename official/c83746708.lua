--魔導師の力
--Mage Power
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--Atk Change
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.value)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(s.value)
	c:RegisterEffect(e3)
end
function s.value(e,c)
	return Duel.GetMatchingGroupCount(Card.IsSpellTrap,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil)*500
end