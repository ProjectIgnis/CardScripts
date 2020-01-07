--Element Sword
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--Atk up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(800)
	e2:SetCondition(s.condition)
	c:RegisterEffect(e2)
end
function s.condition(e)
	local phase=Duel.GetCurrentPhase()
	local ec=e:GetHandler():GetEquipTarget()
	local tc=ec:GetBattleTarget()
	return (phase==PHASE_DAMAGE or phase==PHASE_DAMAGE_CAL)
		and ec and tc and (not ec:IsAttribute(tc:GetAttribute()) and not tc:IsAttribute(ec:GetAttribute()))
end
