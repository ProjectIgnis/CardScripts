-- 卓越風のヴィエトル
-- Vietor the Prevailing Wind
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Give Piercing damage to a WIND monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function() return Duel.IsAbleToEnterBP() end)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
end
function s.filter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:CanGetPiercingRush()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(s.filter),tp,LOCATION_MZONE,0,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local cg=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	if Duel.SendtoGrave(cg,REASON_COST)>0 then
		-- Effect
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
		local g=Duel.SelectMatchingCard(tp,aux.FaceupFilter(s.filter),tp,LOCATION_MZONE,0,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g,true)
			-- Piercing
			g:GetFirst():AddPiercing(RESETS_STANDARD_PHASE_END,e:GetHandler())
		end
	end
end