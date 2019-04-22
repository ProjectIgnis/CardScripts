--Wattdischarge
function c210749504.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(210749504,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c210749504.condition)
	e1:SetCost(c210749504.cost)
	e1:SetTarget(c210749504.target)
	e1:SetOperation(c210749504.activate)
	c:RegisterEffect(e1)
end
function c210749504.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xe) and c:IsAbleToRemove()
end
function c210749504.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c210749504.filter,tp,LOCATION_MZONE,0,1,nil)
		and (re:IsActiveType(TYPE_MONSTER) or re:IsActiveType(TYPE_SPELL) or re:IsActiveType(TYPE_TRAP))
		and Duel.IsChainDisablable(ev)
end
--Banish for cost, then return at end phase
function c210749504.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,c210749504.filter,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(210749504,1))
	local g=Duel.SelectMatchingCard(tp,c210749504.filter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if Duel.Remove(g,POS_FACEUP,REASON_COST+REASON_TEMPORARY)~=0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetRange(LOCATION_REMOVED)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(g)
		e1:SetCountLimit(1)
		e1:SetOperation(c210749504.retop)
		Duel.RegisterEffect(e1,tp)
	end
end
function c210749504.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end
function c210749504.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
--Negate effect, then stun effects of same type
function c210749504.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(0,1)
		if re:IsActiveType(TYPE_MONSTER) then--Stun monster effects
			e1:SetValue(c210749504.aclimit1)
		end
		if re:IsActiveType(TYPE_SPELL) then--Stun spell effects
			e1:SetValue(c210749504.aclimit2)
		end
		if re:IsActiveType(TYPE_TRAP) then--Stun trap effects
			e1:SetValue(c210749504.aclimit3)
		end
		e1:SetReset(RESET_PHASE+Duel.GetCurrentPhase())--Release stun at end of current phase
		Duel.RegisterEffect(e1,tp)
	end
end
function c210749504.aclimit1(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and not re:GetHandler():IsImmuneToEffect(e)
end
function c210749504.aclimit2(e,re,tp)
	return re:IsActiveType(TYPE_SPELL) and not re:GetHandler():IsImmuneToEffect(e)
end
function c210749504.aclimit3(e,re,tp)
	return re:IsActiveType(TYPE_TRAP) and not re:GetHandler():IsImmuneToEffect(e)
end