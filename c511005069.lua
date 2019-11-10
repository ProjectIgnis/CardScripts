--Reverse Damage
--original script by Shad3
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(s.cd)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	--Destroyed
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(s.des_cd)
	e2:SetOperation(s.des_op)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
end
function s.cd(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(tp) or (Duel.GetAttackTarget() and Duel.GetAttackTarget():IsControler(tp))
end
function s.sel_fil(c)
	return c==Duel.GetAttacker() or c==Duel.GetAttackTarget()
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local fg=Duel.GetMatchingGroup(s.sel_fil,tp,LOCATION_MZONE,0,nil)
	local tc
	if #fg==1 then
		tc=fg:GetFirst()
	else
		tc=fg:Select(tp,1,1,nil):GetFirst()
	end
	if not tc then return end
	local c=e:GetHandler()
	c:SetCardTarget(tc)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	tc:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e2:SetOperation(s.dmg_op)
	e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
	e2:SetLabel(Duel.GetBattleDamage(tp)/2)
	c:RegisterEffect(e2)
	e:GetLabelObject():SetLabel(Duel.GetBattleDamage(tp)-e2:GetLabel())
end
function s.dmg_op(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(tp,e:GetLabel())
end
function s.des_cd(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsReason(REASON_DESTROY)
end
function s.des_op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(tp,e:GetLabel(),REASON_EFFECT)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end