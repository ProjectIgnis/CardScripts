--竜星の九支
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x9e}
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9e)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,1,0,0)
	end
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9e)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ec=re:GetHandler()
	if Duel.NegateActivation(ev) and ec:IsRelateToEffect(re) then
		ec:CancelToGrave()
		if Duel.SendtoDeck(ec,nil,2,REASON_EFFECT)~=0 and ec:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
			local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,0,e:GetHandler())
			if #g>0 then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				local sg=g:Select(tp,1,1,nil)
				Duel.Destroy(sg,REASON_EFFECT)
			end
		end
	end
end
