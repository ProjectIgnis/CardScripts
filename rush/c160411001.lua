-- 最強戦旗エースブレイカー
--Ultimate Flag Mech Ace Breaker

--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Destroy 1 face-up monster your opponent controls
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.costfilter(c)
	return c:IsMonster() and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,2,nil) end
end
function s.filter(c)
	return c:IsMonster() and c:IsFaceup() and not c:IsMaximumModeSide()
end
	--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #dg>0 end
end
	--Destroy 1 monster your opponent controls
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,2,2,nil)
	if Duel.SendtoGrave(tg,REASON_COST)==2 then
		local dg=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
		if #dg>0 then
			local sg=dg:Select(tp,1,1,nil)
			sg=sg:AddMaximumCheck()
			Duel.HintSelection(sg)
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end