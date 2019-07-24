--Heroic Growth
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR))
	--Atk Change
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_SET_ATTACK)
	e2:SetCondition(s.condition)
	e2:SetValue(s.value)
	c:RegisterEffect(e2)
end
function s.condition(e)
	return Duel.GetLP(0)~=Duel.GetLP(1)
end
function s.value(e,c)
	local p=e:GetHandler():GetControler()
	if Duel.GetLP(p)<Duel.GetLP(1-p) then
		return c:GetAttack()*2
	elseif Duel.GetLP(p)>Duel.GetLP(1-p) then
		return c:GetAttack()/2
	end
end
