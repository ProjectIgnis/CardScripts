--Total Eclipse
--AlphaKretin
function c210310058.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c210310058.cost)
	e1:SetOperation(c210310058.operation)
	c:RegisterEffect(e1)
end
function c210310058.costfilter(c)
	return c:IsFaceup() and c:IsCode(55794644) and c:IsAbleToRemoveAsCost()
end
function c210310058.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(c210310058.costfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c210310058.costfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if Duel.Remove(g,POS_FACEUP,REASON_COST+REASON_TEMPORARY)~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(g:GetFirst())
		e1:SetCountLimit(1)
		e1:SetOperation(c210310058.retop)
		Duel.RegisterEffect(e1,tp)
	end
end
function c210310058.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end
function c210310058.operation(e,tp,eg,ep,ev,re,r,rp)
	local boo=Duel.IsEnvironment(56433456) and 1 or 0
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x44))
	e1:SetLabel(boo)
	e1:SetValue(c210310058.efilter)
	Duel.RegisterEffect(e1,tp)
end
function c210310058.efilter(e,te)
	if te:IsActiveType(TYPE_SPELL+TYPE_TRAP) then return true end
	if te:IsActiveType(TYPE_MONSTER) then return e:GetLabel()>0 end
	return false
end