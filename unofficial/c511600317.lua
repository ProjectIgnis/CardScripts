--－Ａｉ－サツ
--HA.I.
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)--EFFECT_COUNT_CODE_OATH
	e1:SetCondition(s.condition)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DAMAGE)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if r&REASON_EFFECT~=0 then
		Duel.RegisterFlagEffect(ep,id,RESET_PHASE+PHASE_END,0,1)
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttackTarget() and Duel.GetTurnPlayer()~=tp and Duel.GetFlagEffect(tp,id)>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetAttackTarget():GetAttack()~=Duel.GetAttacker():GetAttack() end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
	local ac=Duel.GetAttacker()
	if not ac:IsControler(tp) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,ac,1,0,0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.GetAttacker()
	local bc=Duel.GetAttackTarget()
	if Duel.Damage(1-tp,2*math.abs(ac:GetAttack()-bc:GetAttack()),REASON_EFFECT)>0
		and not ac:IsControler(tp) and ac:IsDestructable() and ac:IsRelateToBattle() then
		Duel.BreakEffect()
		Duel.Destroy(ac,REASON_EFFECT)
	end
end
