--ハーピィ・レディ３
--Harpie Lady 3 (Rush)
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Name becomes "Harpie Lady" while in the GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetValue(CARD_HARPIE_LADY)
	c:RegisterEffect(e1)
	--Change name to "Harpie Lady" and prevent a monster from attacking
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.cost)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_HARPIE_LADY}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
end
function s.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(8)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- Requirement
	if Duel.DiscardDeck(tp,1,REASON_COST)<1 then return end
	--Effect
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetValue(CARD_HARPIE_LADY)
	e1:SetReset(RESETS_STANDARD_PHASE_END,2)
	c:RegisterEffect(e1)
	if Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.filter),tp,0,LOCATION_MZONE,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local tc=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.filter),tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
		if not tc then return end
		Duel.BreakEffect()
		Duel.HintSelection(tc)
		--Cannot attack
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(3206)
		e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_ATTACK)
		e2:SetCondition(function(e) return Duel.IsTurnPlayer(1-e:GetOwnerPlayer()) end)
		e2:SetReset(RESETS_STANDARD_PHASE_END|RESET_SELF_TURN,1)
		tc:RegisterEffect(e2)
	end
end