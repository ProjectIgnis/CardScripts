--Reaction Star Mirror
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--Deflect
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.con)
	e3:SetOperation(s.op)
	c:RegisterEffect(e3)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	local eq=e:GetHandler():GetEquipTarget()
	return (Duel.GetAttacker()==eq or (Duel.GetAttackTarget() and Duel.GetAttackTarget()==eq))
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandler():GetEquipTarget():GetControler()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	Duel.RegisterEffect(e1,p)
end
