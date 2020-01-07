--バスターランチャー
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsAttackBelow,1000),s.eqlimit)
	--Atk,def
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(s.atkcon)
	e2:SetValue(2500)
	c:RegisterEffect(e2)
end
function s.eqlimit(e,c)
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL or c:IsAttackBelow(1000)
end
function s.atkcon(e)
	local ec=e:GetHandler():GetEquipTarget()
	if not ec:IsRelateToBattle() then return end
	local bc=ec:GetBattleTarget()
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and bc
		and ((bc:IsAttackPos() and bc:IsAttackAbove(2500)) or (bc:IsDefensePos() and bc:IsDefenseAbove(2500)))
end
