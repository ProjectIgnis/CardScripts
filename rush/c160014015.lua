--火轟嵐凰ヴォルカライズ・フェニックス［Ｌ］
--Blazebolt Chemistorm Fenghuang Volcalize Phoenix [L]
local s,id=GetID()
function s.initial_effect(c)
	--Destroy 1 level 9 monster, then destroy 1 monster if in max mode
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	c:AddSideMaximumHandler(e1)
end
s.MaximumSide="Left"
function s.costfilter(c)
	return c:IsRace(RACE_THUNDER) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsMonster() and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(9)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,e:GetHandler())
	if chk==0 then return #dg>0 end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tdg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.HintSelection(tdg,true)
	if Duel.SendtoDeck(tdg,nil,SEQ_DECKSHUFFLE,REASON_COST)~=1 then return end
	--Effect
	local dg=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(s.desfilter),tp,0,LOCATION_MZONE,nil)
	if #dg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=dg:Select(tp,1,1,nil)
		sg=sg:AddMaximumCheck()
		Duel.HintSelection(sg,true)
		if Duel.Destroy(sg,REASON_EFFECT)>0 then
			local sg=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(Card.IsMonster),tp,0,LOCATION_MZONE,nil)
			if e:GetHandler():IsMaximumMode() and #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				local tg=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(Card.IsMonster),tp,0,LOCATION_MZONE,1,1,nil)
				if #tg>0 then
					tg=tg:AddMaximumCheck()
					Duel.HintSelection(tg,true)
					Duel.Destroy(tg,REASON_EFFECT)
				end
			end
		end
	end
end