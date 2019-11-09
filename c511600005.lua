--Magicians Unite (Manga)
--マジシャンズ・クロス
--scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--atkup
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.condition)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:GetAttackedCount()==0 and c:CanAttack()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	return at:IsControler(tp) and at:IsRace(RACE_SPELLCASTER) 
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,at)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetAttacker()
	if Duel.SelectEffectYesNo(tp,c) then
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,tc)
		for sc in aux.Next(g) do
			tc:SetCardTarget(sc)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			sc:RegisterEffect(e1)
		end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetCondition(s.atkcon)
		e1:SetValue(3000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
		e2:SetCode(EVENT_LEAVE_FIELD)
		e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
		e2:SetOperation(s.desop)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e3:SetCode(EVENT_DAMAGE_STEP_END)
		e3:SetRange(LOCATION_MZONE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetOperation(s.reset)
		tc:RegisterEffect(e3)
	end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCardTargetCount()>0
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetCardTarget():Filter(Card.IsLocation,nil,LOCATION_MZONE)
	if c:IsReason(REASON_DESTROY+REASON_BATTLE) and #g>0 then
		Duel.Destroy(g,REASON_BATTLE)
	end
	e:Reset()
end
function s.reset(e,tp,eg,ep,ev,re,r,rp)
	for tc in aux.Next(e:GetHandler():GetCardTarget()) do
		e:GetHandler():CancelCardTarget(tc)
	end
	e:Reset()
end
