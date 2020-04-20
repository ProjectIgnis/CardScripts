--ダークネス １
function c100000591.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c100000591.descon)
	e1:SetTarget(c100000591.destg)
	e1:SetOperation(c100000591.desop)
	c:RegisterEffect(e1)
end
function c100000591.descon(e,tp,eg,ep,ev,re,r,rp)
	return false
end
function c100000591.cfilter(c)
	return c:IsFaceup() and (c:IsCode(100000591) or c:IsCode(100000592) or c:IsCode(100000593))
end
function c100000591.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
	local ct=Duel.GetMatchingGroupCount(c100000591.cfilter,tp,LOCATION_ONFIELD,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,ct,0,0)
end
function c100000591.filter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
function c100000591.desop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(c100000591.cfilter,tp,LOCATION_ONFIELD,0,nil)
	if Duel.GetMatchingGroupCount(Card.IsDestructable,tp,0,LOCATION_ONFIELD,nil)>=ct then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,Card.IsDestructable,tp,0,LOCATION_ONFIELD,ct,ct,nil)
		Duel.Destroy(g,REASON_EFFECT)
	end
end
