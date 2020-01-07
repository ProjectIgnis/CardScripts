--Superior Overlay
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c,ct)
	return c:IsType(TYPE_XYZ) and c:GetOverlayCount()>ct
end
function s.ofilter(c)
	return c:IsType(TYPE_XYZ) and (c:GetOverlayCount()>0 or c:IsFaceup())
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local og=Duel.GetMatchingGroup(s.ofilter,tp,0,LOCATION_MZONE,nil)
	local ct=og:GetSum(Card.GetOverlayCount)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,ct)
end
function s.filter(c)
	return c:IsType(TYPE_XYZ) and (c:GetOverlayCount()>0 or c:IsFaceup()) and c:IsDestructable()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	local sg=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	local dg=sg:Filter(Card.CheckRemoveOverlayCard,nil,1-tp,1,REASON_EFFECT)
	if #dg>0 and Duel.SelectYesNo(1-tp,aux.Stringid(81330115,0)) then
		local g=dg:Select(1-tp,1,10,nil)
		sg:Sub(g)
		local tc=g:GetFirst()
		while tc do
			tc:RemoveOverlayCard(1-tp,1,1,REASON_EFFECT)
			tc=g:GetNext()
		end
	end
	Duel.Destroy(sg,REASON_EFFECT)
end
