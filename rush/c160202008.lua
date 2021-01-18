--マジカルテット・ショック
--Magiquartet Shock

--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Destroy 1 of opponent's monsters
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
	--Check if opponent special summoned a monster with 1500+ ATK
function s.filter(c,e,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsAttackAbove(1500) and c:IsSummonPlayer(1-tp)
end
	--If it ever happened
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,e,tp)
end
	--Check for normal monsters to shuffle to deck as cost
function s.cfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToDeckAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,4,nil) end
end
	--Check for a monster to destroy
function s.desfilter(c)
	return c:IsType(TYPE_MONSTER) and not c:IsMaximumModeSide()
end
	--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetChainLimit(s.chlimit)
end
function s.chlimit(e,ep,tp)
	return not e:IsHasType(EFFECT_TYPE_ACTIVATE)
end
	--Destroy 1 of opponent's monsters
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,4,4,nil)
	Duel.HintSelection(g)
	if #g>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)>0 then
		--Effect
		local dg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
		local sg=dg:Select(tp,1,1,nil)
		if #sg>0 then
			Duel.HintSelection(sg)
			sg=sg:AddMaximumCheck()
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end