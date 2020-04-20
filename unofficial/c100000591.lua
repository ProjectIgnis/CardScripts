--ダークネス １
--Darkness 1
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
s.listed_names={id+1,100000593}
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return false
end
function s.cfilter(c)
	return c:IsFaceup() and (c:IsCode(id) or c:IsCode(id+1) or c:IsCode(100000593))
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_ONFIELD,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,ct,0,0)
end
function s.filter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_ONFIELD,0,nil)
	if Duel.GetMatchingGroupCount(Card.IsDestructable,tp,0,LOCATION_ONFIELD,nil)>=ct then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,Card.IsDestructable,tp,0,LOCATION_ONFIELD,ct,ct,nil)
		Duel.Destroy(g,REASON_EFFECT)
	end
end
