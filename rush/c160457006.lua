--プラネット・イージス
--Planet Aegis
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Make 1 monster lose 600 ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,2) end
end
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_GALAXY) and c:IsNotMaximumModeSide()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil) end
end
function s.filter2(c)
	return c:IsSpellTrap() and (not c:IsHasEffect(EFFECT_CANNOT_TO_DECK) or not c:IsHasEffect(EFFECT_CANNOT_TO_HAND))
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	if Duel.DiscardDeck(tp,2,REASON_COST)<2 then return end
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	if Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_ONFIELD,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
		local tg=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_ONFIELD,0,1,1,nil)
		g:Merge(tg)
	end
	Duel.HintSelection(g)
	for tc in g:Iter() do
		--Effect
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TO_DECK)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetCondition(s.indcond)
		e1:SetValue(1)
		e1:SetReset(RESETS_STANDARD_PHASE_END,2)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_TO_HAND)
		tc:RegisterEffect(e2)
	end
end
function s.indcond(e)
	return Duel.IsTurnPlayer(1-e:GetHandlerPlayer())
end