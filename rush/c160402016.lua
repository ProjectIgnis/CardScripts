--ライステラス・セキュア
--Raistellas Secure
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Switch to defense
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.tgfilter(c)
	return c:IsLevelAbove(5) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND,0,1,nil) end
end
function s.nonaquafilter(c)
	return c:IsAttackPos() and not c:IsRace(RACE_AQUA) and c:IsCanChangePosition()
end
function s.aquafilter(c)
	return c:IsRace(RACE_AQUA) and c:IsFaceup()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.aquafilter),tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.nonaquafilter),tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,1-tp,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tg=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	if Duel.SendtoGrave(tg,REASON_COST)>0 then
	--Effect
		local ct=Duel.GetMatchingGroupCount(aux.FilterMaximumSideFunctionEx(s.aquafilter),tp,LOCATION_MZONE,0,nil)
		if ct==0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
		local pg=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.nonaquafilter),tp,0,LOCATION_MZONE,1,ct,nil)
		if #pg>0 then
			Duel.ChangePosition(pg,POS_FACEUP_DEFENSE)
		end
	end
end