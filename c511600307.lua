--Ａｉ打ち
--TAi Strike
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local bc=Duel.GetAttackTarget()
	if not bc then return false end
	local tc=Duel.GetAttacker()
	if not tc:IsControler(tp) then tc,bc=bc,tc end
	e:SetLabelObject(tc)
	return tc:IsControler(tp) and tc:IsSetCard(0x582) and not bc:IsControler(tp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local bc=tc:GetBattleTarget()
	if tc:IsRelateToBattle() and not tc:IsImmuneToEffect(e)
		and tc:IsControler(tp) and not bc:IsControler(tp) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(bc:GetAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		tc:RegisterEffect(e1)
	end
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetOperation(s.damop)
	e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
	Duel.RegisterEffect(e2,tp)
end
function s.damage(c)
	if c:GetReason()&0x21==0x21 then 
		Duel.Damage(c:GetPreviousControler(),c:GetBaseAttack(),REASON_EFFECT)
	end
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	s.damage(Duel.GetAttacker())
	s.damage(Duel.GetAttackTarget())
end
