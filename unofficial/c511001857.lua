--ラスト・トリック
--Last Trick
local s,id=GetID()
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_DRAW_PHASE)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_ACTIVATING)
	e1:SetOperation(s.regop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rp==tp or not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not re:IsActiveType(TYPE_SPELL) then return end
	local e1=Effect.CreateEffect(e:GetOwner())
	e1:SetCode(EVENT_LEAVE_FIELD_P)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCondition(function(e)return e:GetHandler():GetDestination()==LOCATION_GRAVE end)
	e1:SetOperation(s.repop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	rc:RegisterEffect(e1)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local p=e:GetOwner():GetOwner()
	Duel.SendtoHand(c,p,REASON_EFFECT)
	Duel.ConfirmCards(1-p,c)
end