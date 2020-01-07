--Emperor's Armor
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--Attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_SET_ATTACK)
	e3:SetCondition(s.atkcon)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	--Save Monster
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end
function s.atkcon(e)
	local eq=e:GetHandler():GetEquipTarget()
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and (Duel.GetAttacker()==eq or Duel.GetAttackTarget()==eq) and Duel.GetAttackTarget()~=nil 
end
function s.atkval(e,c)
	local eq=e:GetHandler():GetEquipTarget()
	return eq:GetBattleTarget():GetAttack()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tg=c:GetEquipTarget()
	if chk==0 then return c and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
		and tg and tg:IsReason(REASON_BATTLE) end
	return Duel.SelectYesNo(tp,aux.Stringid(id,0))
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=c:GetEquipTarget()
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
	local bt=tg:GetBattleTarget()
	local ph=Duel.GetCurrentPhase()
	if Duel.GetTurnPlayer()==tp and ph>=0x08 and ph<=0x20 and Duel.GetTurnPlayer()==tp then
		if Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,bt) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,bt):GetFirst()
			local atk1=tg:GetAttack()
			local atk2=g:GetAttack()
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK)
			e1:SetValue(atk2)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tg:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_SET_ATTACK)
			e2:SetValue(atk1)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			g:RegisterEffect(e2)
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_EXTRA_ATTACK)
			e3:SetValue(1)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
			tg:RegisterEffect(e3)
		end
	end
end
