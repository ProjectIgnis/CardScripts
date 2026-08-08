--デカラケ
--Giant Racket
local s,id=GetID()
function s.initial_effect(c)
	--Equip only to "The Big Server"
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsCode,511000644))
	--Once per turn, the equipped monster cannot be destroyed by battle, and its controller takes no Battle Damage from that battle.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.batindesnobatdamcon)
	e1:SetOperation(s.batindesnobatdamop)
	c:RegisterEffect(e1)
end
s.listed_names={511000644} --"The Big Server"
function s.batindesnobatdamcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	local bc=tc:GetBattleTarget()
	if tc~=e:GetHandler():GetEquipTarget() then
		tc=Duel.GetAttackTarget()
		bc=Duel.GetAttacker()
	end
	if not tc or not bc or tc~=e:GetHandler():GetEquipTarget() or tc:IsHasEffect(EFFECT_INDESTRUCTABLE_BATTLE) then return false end
	if bc==Duel.GetAttackTarget() and bc:IsDefensePos() then return false end
	if bc:IsPosition(POS_FACEUP_DEFENSE) and bc==Duel.GetAttacker() then
		if not bc:IsHasEffect(EFFECT_DEFENSE_ATTACK) then return false end
		if bc:IsHasEffect(EFFECT_DEFENSE_ATTACK) then
			if bc:GetEffectCount(EFFECT_DEFENSE_ATTACK)==1 then
				if tc:IsAttackPos() then
					if bc:GetDefense()==tc:GetAttack() and not bc:IsHasEffect(EFFECT_INDESTRUCTABLE_BATTLE) then
						return bc:GetDefense()~=0
					else
						return bc:GetDefense()>=tc:GetAttack()
					end
				else
					return bc:GetDefense()>tc:GetDefense()
				end
			elseif bc:IsHasEffect(EFFECT_DEFENSE_ATTACK) then
				if tc:IsAttackPos() then
					if bc:GetAttack()==tc:GetAttack() and not bc:IsHasEffect(EFFECT_INDESTRUCTABLE_BATTLE) then
						return bc:GetAttack()~=0
					else
						return bc:GetAttack()>=tc:GetAttack()
					end
				else
					return bc:GetAttack()>tc:GetDefense()
				end
			end
		end
	else
		if tc:IsAttackPos() then
			if bc:GetAttack()==tc:GetAttack() and not bc:IsHasEffect(EFFECT_INDESTRUCTABLE_BATTLE) then
				return bc:GetAttack()~=0
			else
				return bc:GetAttack()>=tc:GetAttack()
			end
		else
			return bc:GetAttack()>tc:GetDefense()
		end
	end
end
function s.batindesnobatdamop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local eq=c:GetEquipTarget()
	if eq then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_PHASE|PHASE_DAMAGE)
		eq:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(1,0)
		e2:SetValue(1)
		e2:SetReset(RESET_PHASE|PHASE_DAMAGE)
		Duel.RegisterEffect(e2,eq:GetControler())
	end
end
