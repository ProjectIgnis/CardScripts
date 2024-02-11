--獣機界王グライダー・フォックス
--Beast Gear Emperor Glider Fox
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Destroy 1 monster the opponent controls
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
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
	return c:IsRace(RACE_BEASTWARRIOR) and c:IsAttackAbove(1500) and c:IsFaceup() and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsLevelBelow,8),tp,0,LOCATION_MZONE,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	if Duel.SendtoGrave(tg,REASON_COST)>0 then
		--Effect
		local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsLevelBelow,8),tp,0,LOCATION_MZONE,nil)
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local dg=g:Select(tp,1,1,nil)
			dg:AddMaximumCheck()
			Duel.HintSelection(dg,true)
			Duel.Destroy(dg,REASON_EFFECT)
		end
		--Prevent non-Warriors from attacking
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_OATH)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(s.ftarget)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.ftarget(e,c)
	return not c:IsRace(RACE_BEASTWARRIOR)
end