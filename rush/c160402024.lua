--トランザム・ライカー
--Transamu Raiker
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	-- Give Piercing effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsAbleToEnterBP()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
end
function s.filter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_GALAXY) and not c:IsHasEffect(EFFECT_CANNOT_ATTACK)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(s.filter),tp,LOCATION_MZONE,0,1,nil) end
end
function s.posfilter(c)
	return c:IsFaceup() and c:IsCanChangePositionRush()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local cg=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	if Duel.SendtoGrave(cg,REASON_COST)>0 then
		-- Effect
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local g=Duel.SelectMatchingCard(tp,aux.FaceupFilter(s.filter),tp,LOCATION_MZONE,0,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g,true)
			-- Piercing
			g:GetFirst():AddPiercing(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,c)
			if not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,160425001),tp,LOCATION_MZONE,0,1,nil) then return end
			local sg=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(s.posfilter),tp,0,LOCATION_MZONE,nil)
			if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
				local sc=Group.Select(sg,tp,1,1,nil)
				if #sc==0 then return end
				Duel.HintSelection(sc,true)
				Duel.BreakEffect()
				Duel.ChangePosition(sc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
			end
		end
	end
end

