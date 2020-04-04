--Command Duel 8
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
function s.filter(c)
	return c:IsDestructable() and c:IsFacedown()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_ONFIELD,nil)
	local g2=Duel.GetMatchingGroup(s.filter,1-tp,0,LOCATION_ONFIELD,nil)
	local g=Group.CreateGroup()
	if #g1>0 and Duel.SelectYesNo(tp,aux.Stringid(8041569,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg1=g1:Select(tp,1,1,nil)
		g:Merge(sg1)
	end
	if #g2>0 and Duel.SelectYesNo(1-tp,aux.Stringid(8041569,0)) then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_DESTROY)
		local sg2=g2:Select(1-tp,1,1,nil)
		g:Merge(sg2)
	end
	Duel.Destroy(g,REASON_EFFECT)
end
