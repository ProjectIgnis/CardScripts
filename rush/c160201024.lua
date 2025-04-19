--キングス・リワード
--King's Reward
local s,id=GetID()
function s.initial_effect(c)
	--Destroy 1 of opponent's level 6 or lower monsters
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsType(TYPE_NORMAL) and c:IsMonster() and c:IsRace(RACE_FIEND) and c:IsLevel(1) and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMatchingGroupCount(aux.FilterMaximumSideFunctionEx(s.desfilter),tp,0,LOCATION_MZONE,e:GetHandler())>0 end
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(6)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.HintSelection(g)
	if #g>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)>0 then
		--Effect
		local dg=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(s.desfilter),tp,0,LOCATION_MZONE,e:GetHandler())
		if #dg>0 then
			local sg=dg:Select(tp,1,1,nil)
			sg=sg:AddMaximumCheck()
			Duel.HintSelection(sg)
			if Duel.Destroy(sg,REASON_EFFECT)>0 then
				Duel.Draw(1-tp,1,REASON_EFFECT)
				--Cannot attack directly this turn
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
				e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				e1:SetTargetRange(LOCATION_MZONE,0)
				e1:SetReset(RESET_PHASE|PHASE_END)
				Duel.RegisterEffect(e1,tp)
			end
		end
	end
end