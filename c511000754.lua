--Parallel Twister
--updated by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.dfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsDestructable() and Duel.IsExistingMatchingCard(s.dfilter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
function s.dfilter2(c,s)
	return c:IsDestructable()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	local dg=Duel.GetMatchingGroup(s.dfilter,tp,LOCATION_ONFIELD,0,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,2,0,LOCATION_ONFIELD)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local dg=Duel.SelectMatchingCard(tp,s.dfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	Duel.Destroy(dg,REASON_EFFECT)
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local dg2=Duel.SelectMatchingCard(tp,s.dfilter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	Duel.Destroy(dg2,REASON_EFFECT)
end