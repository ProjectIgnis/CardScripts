--神風剣
--Kamikaze Blade
--Scripted by Naim

local s,id=GetID()
function s.initial_effect(c)
	--Destroy monsters
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter1(c,e)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and not c:IsMaximumModeSide() and c:IsDestructable(e)
end
function s.filter2(c,e)
	return c:IsFaceup() and c:HasLevel() and c:IsLevelBelow(8) and not c:IsMaximumModeSide() and c:IsDestructable(e)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_MZONE,0,nil,e)
	local g2=Duel.GetMatchingGroup(s.filter2,tp,0,LOCATION_MZONE,nil,e)
	if chk==0 then return #g1>1 and #g2>0 end
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,3,0,LOCATION_MZONE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_MZONE,0,2,2,nil,e)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g2=Duel.SelectMatchingCard(tp,s.filter2,tp,0,LOCATION_MZONE,1,1,nil,e)
	g1:Merge(g2)
	Duel.HintSelection(g1)
	if #g1==3 then
		g1=g1:AddMaximumCheck()
		Duel.Destroy(g1,REASON_EFFECT)
	end
end