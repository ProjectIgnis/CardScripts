--死者の加護
--Aid to the Doomed
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Can activate from hand during opponent's turn
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.actcon)
	e2:SetLabel(0)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsPreviousControler,1,nil,tp)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local label=e:GetLabelObject():GetLabel()
	if chk==0 then
		if label==1 then
			return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,2,e:GetHandler())
		elseif label==0 then
			return true
		end
	end
	if label==1 then
		Duel.DiscardHand(tp,Card.IsDiscardable,2,2,REASON_COST+REASON_DISCARD,e:GetHandler())
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.SkipPhase(Duel.GetTurnPlayer(),PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
end
function s.actcon(e)
	if Duel.IsExistingMatchingCard(Card.IsDiscardable,e:GetHandlerPlayer(),LOCATION_HAND,0,2,e:GetHandler()) then
		e:SetLabel(1)
		return true
	else
		e:SetLabel(0)
		return false
	end
end
