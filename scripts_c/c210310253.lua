--Unexpected Daidalus
function c210310253.initial_effect(c)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37721209,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c210310253.cost)
	e1:SetTarget(c210310253.target)
	e1:SetOperation(c210310253.operation)
	c:RegisterEffect(e1)
end
function c210310253.cfilter(c)
	return c:IsFaceup() and ((c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_EFFECT) and c:IsLevelBelow(4))
		or (c:IsSetCard(0xf36) or c:IsCode(911883))) and c:IsAbleToGraveAsCost()
end
function c210310253.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210310253.cfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c210310253.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function c210310253.desfilter(c)
	if c:IsFaceup() then
		return not ((c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_EFFECT) and c:IsLevelBelow(4))
			or (c:IsSetCard(0xf36) or c:IsCode(911883)))
	else
		return true
	end
end
function c210310253.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210310253.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	local g=Duel.GetMatchingGroup(c210310253.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function c210310253.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c210310253.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	Duel.Destroy(g,REASON_EFFECT)
end