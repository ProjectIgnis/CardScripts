--お母さんの嵐
--Mother's Storm
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Destroy 1 of opponent's level 8 or lower monsters
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_AQUA) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_AQUA) and c:IsLevelAbove(8)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(8) 
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	local tg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	if Duel.SendtoGrave(tg,REASON_COST)==1 then
		--Effect
		local dg=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(s.desfilter),tp,0,LOCATION_MZONE,nil)
		if #dg>0 then
			local sg=dg:Select(tp,1,1,nil)
			sg=sg:AddMaximumCheck()
			Duel.HintSelection(sg)
			if Duel.Destroy(sg,REASON_EFFECT)>0 and sg:GetFirst():GetPreviousRaceOnField()&RACE_MACHINE~=0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
				local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
				Duel.Destroy(sg,REASON_EFFECT)
			end
		end
	end
end