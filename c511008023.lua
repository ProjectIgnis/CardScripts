--Dauntless Challenge
--Scripted by Snrk
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.atkcon)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
end
--activate
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local at=Duel.GetAttackTarget()
	if not a or not at then return end
	return a:IsControler(tp) and a:GetAttack()<=at:GetAttack()
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local at=Duel.GetAttackTarget()
	if not a:IsRelateToBattle() or not at:IsRelateToBattle() then return end
	--double attack
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(a:GetAttack()*2)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	a:RegisterEffect(e1)
	--destroy spell
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)	  
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
	e2:SetOperation(s.desop)
	Duel.RegisterEffect(e2,tp)
end
--destroy spell
function s.sfilter(c)
	return c:IsFacedown() or c:IsType(TYPE_SPELL)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local at=Duel.GetAttackTarget()
	if a:IsControler(tp) and at:IsControler(1-tp) and a:IsOnField() and at and a:IsRelateToBattle() and not at:IsRelateToBattle() then return true end
	return false
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and s.sfilter(chkc) end
	if chk==0 then return true end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local target=Duel.SelectMatchingCard(tp,s.sfilter,tp,0,LOCATION_SZONE,1,1,nil)
	if not g then return end
	local g=target:GetFirst()
	if g:IsFacedown() then Duel.ConfirmCards(tp,g) end
	if g:IsType(TYPE_SPELL) then Duel.Destroy(g,REASON_EFFECT) end
end