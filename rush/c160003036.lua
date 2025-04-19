--ルミナス・パロット
--Luminous Parrot

local s,id=GetID()
function s.initial_effect(c)
	--Change selected monster's attribute to LIGHT
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCountRush(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)>1
end
function s.attfilter(c)
	return c:IsFaceup() and c:CanChangeIntoAttributeRush(ATTRIBUTE_LIGHT) and c:IsNotMaximumModeSide()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.attfilter,tp,0,LOCATION_MZONE,1,e:GetHandler()) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	if Duel.DiscardDeck(tp,1,REASON_COST)==1 then
		--Effect
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)
		local g=Duel.SelectMatchingCard(tp,s.attfilter,tp,0,LOCATION_MZONE,1,1,e:GetHandler())
		Duel.HintSelection(g)
		if #g>0 then
			local tc=g:GetFirst()
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e1:SetValue(ATTRIBUTE_LIGHT)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			tc:RegisterEffect(e1,true)
		end
	end
end