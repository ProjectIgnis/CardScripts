--終焔魔神ディスペラシオン
--Doomblaze Fiend Overlord Despairacion
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	Maximum.AddProcedure(c,nil,s.filter1,s.filter2)
	--Destroy 1 card your opponent controls
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
	c:AddMaximumAtkHandler()
end
s.MaximumAttack=4000
function s.filter1(c)
	return c:IsCode(160205007)
end
function s.filter2(c)
	return c:IsCode(160205009)
end
function s.costfilter(c)
	return c:IsMonster() and c:IsType(TYPE_MAXIMUM) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,2,nil) end
end
function s.filter(c)
	return not c:IsMaximumModeSide()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local dg=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #dg>0 and (not c:IsMaximumMode() or Duel.IsPlayerCanDraw(tp,2)) end
	if c:IsMaximumMode() then
		Duel.SetTargetPlayer(tp)
		Duel.SetTargetParam(2)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,2,2,nil)
	if Duel.SendtoGrave(tg,REASON_COST)==2 then
		local dg=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_ONFIELD,nil)
		if #dg>0 then
			local sg=dg:Select(tp,1,1,nil)
			sg=sg:AddMaximumCheck()
			Duel.HintSelection(sg,true)
			Duel.Destroy(sg,REASON_EFFECT)
			if c:IsMaximumMode() then
				Duel.BreakEffect()
				local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
				Duel.Draw(p,d,REASON_EFFECT)
			end
		end
	end
end
