--大貫通！！
--Powerful Pierce!!
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(function() return Duel.IsAbleToEnterBP() end)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsAbleToEnterBP()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,e:GetHandler()) end
end
function s.filter1(c,tp)
	return c:IsFaceup() and c:HasLevel() and c:CanGetPiercingRush() and not c:IsMaximumModeSide()
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_MZONE,0,1,c,c:GetLevel())
end
function s.filter2(c,lvl)
	return c:IsFaceup() and c:IsLevel(lvl) and c:CanGetPiercingRush() and not c:IsMaximumModeSide()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_MZONE,0,1,nil,tp) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	if Duel.SendtoGrave(g,REASON_COST)==0 then return end
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc1=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc2=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_MZONE,0,1,1,tc1,tc1:GetLevel()):GetFirst()
	local g=Group.FromCards(tc1,tc2)
	Duel.HintSelection(g,true)
	for tc in g:Iter() do
		tc:AddPiercing(RESETS_STANDARD_PHASE_END,e:GetHandler())
	end
end