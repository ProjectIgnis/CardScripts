--ライステラス・リペル
--Rice Terrace Ripple
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Send the top 2 cards from the Deck to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_POSITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_SUMMON_TURN)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,2) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DECKDES,nil,2,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_POSITION,nil,1,tp,0)
end
function s.cfilter(c)
	return c:IsFace() and c:IsType(TYPE_NORMAL) and c:IsCanChangePosition()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.DiscardDeck(tp,2,REASON_EFFECT)
	if Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil)
		and Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.cfilter),tp,0,LOCATION_MZONE,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local tc=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.cfilter),tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
		if tc then
			Duel.BreakEffect()
			Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		end
	end
end