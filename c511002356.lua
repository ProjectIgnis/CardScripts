--Voltic Spear
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR))
	--atk up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.value)
	c:RegisterEffect(e2)
end
s.listed_names={9327502}
function s.value(e,c)
	local ec=e:GetHandler():GetEquipTarget()
	if ec:IsCode(9327502) then
		return 1000
	else
		return 300
	end
end
