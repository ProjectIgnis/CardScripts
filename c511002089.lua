--瞬間氷結
--Instant Freeze
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev) and not re:GetHandler():IsType(TYPE_PENDULUM)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_POSITION,eg,1,0,0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ec=re:GetHandler()
	Duel.NegateActivation(ev)
	if re:GetHandler():IsRelateToEffect(re) then
		ec:CancelToGrave()
		Duel.ChangePosition(ec,POS_FACEDOWN)
		ec:SetStatus(STATUS_ACTIVATE_DISABLED,false)
		Duel.RaiseEvent(ec,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		if Duel.GetTurnPlayer()==ec:GetControler() then
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,3)
		else
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,3)
		end
		e1:SetValue(1)
		ec:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetLabelObject(e1)
		e2:SetCondition(s.turncon)
		e2:SetOperation(s.turnop)
		e2:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,3)
		Duel.RegisterEffect(e2,Duel.GetTurnPlayer())
		local descnum=tp==c:GetOwner() and 0 or 1
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetDescription(aux.Stringid(4931121,descnum))
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
		e3:SetCode(1082946)
		e3:SetLabelObject(e2)
		e3:SetOwnerPlayer(tp)
		e3:SetOperation(s.reset)
		if Duel.GetTurnPlayer()==tp then
			e3:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,3)
		else
			e3:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,3)
		end
		c:RegisterEffect(e3)
	end
end
function s.reset(e,tp,eg,ep,ev,re,r,rp)
	s.turnop(e:GetLabelObject(),tp,eg,ep,ev,e,r,rp)
end
function s.turncon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function s.turnop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()+1
	e:SetLabel(ct)
	e:GetHandler():SetTurnCounter(ct)
	if ct==3 then
		if e:GetLabelObject() then e:GetLabelObject():Reset() end
		if re then re:Reset() end
	end
end