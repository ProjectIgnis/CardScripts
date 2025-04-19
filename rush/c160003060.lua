--背誤射撃
--Faulty Fire
local s,id=GetID()
function s.initial_effect(c)
	--Destroy 1 of opponent's level 6 or lower effect monsters
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,tp)
	return c:IsSpellTrap() and c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousControler(tp)
		and (c:GetReason()&(REASON_EFFECT+REASON_DESTROY))==(REASON_EFFECT+REASON_DESTROY)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and eg:IsExists(s.filter,1,nil,tp)
end
function s.desfilter(c)
	return c:IsType(TYPE_EFFECT) and c:IsLevelBelow(6)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_ONFIELD,1,e:GetHandler()) end
	local g=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(s.desfilter),tp,0,LOCATION_ONFIELD,e:GetHandler())
	if #g>0 then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local dg=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(s.desfilter),tp,0,LOCATION_MZONE,nil)
	local sg=dg:Select(tp,1,1,nil)
	if #sg>0 then
		Duel.HintSelection(sg)
		sg=sg:AddMaximumCheck()
		Duel.Destroy(sg,REASON_EFFECT)
	end
end