--Blizzard Wall
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local d=Duel.GetAttackTarget()
	if chk==0 then return d and d:IsControler(tp) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,d,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttackTarget()
	if tc and tc:IsRelateToBattle() then
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_BATTLE_DESTROYED)
		e1:SetOperation(s.ctop)
		tc:RegisterEffect(e1)
	end
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetAttacker() and e:GetHandler():GetReasonCard() and e:GetHandler():GetReasonCard()==Duel.GetAttacker() then
		Duel.Hint(HINT_CARD,0,id)
		Duel.GetAttacker():AddCounter(0x1015,1,REASON_EFFECT)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(s.bpcon)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
	e:Reset()
end
function s.bpcon(e)
	if e:GetHandler():GetCounter(0x1015)>0 then
		return true
	else
		e:Reset()
		return false
	end
end
