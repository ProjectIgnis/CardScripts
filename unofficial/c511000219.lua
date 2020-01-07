--Matter Leveller
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsCode,10992251))
	--Attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_SET_ATTACK)
	e3:SetCondition(s.condtion)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
end
function s.condtion(e)
	local eq=e:GetHandler():GetEquipTarget()
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and Duel.GetAttacker()==eq and Duel.GetAttackTarget()~=nil 
		and Duel.GetAttackTarget():IsDefensePos()
end
function s.atkval(e,c)
	return Duel.GetAttackTarget():GetDefense()+100
end
