--火中の栗
--Chestnuts Out of the Fire

--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
	--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
	--Send the top card of deck to GY
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.DiscardDeck(tp,1,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	local ct=g:GetFirst()
	if ct then
		--If it was a monster, make 1 warrior monster gain ATK equal to sent monster's level x 300 and take damage equal to that amount
		if ct:IsType(TYPE_MONSTER) and Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsRace,RACE_WARRIOR),tp,LOCATION_MZONE,0,1,nil) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
			local tc=Duel.SelectMatchingCard(tp,aux.FilterFaceupFunction(Card.IsRace,RACE_WARRIOR),tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
			Duel.HintSelection(Group.FromCards(tc))
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(ct:GetLevel()*300)
			tc:RegisterEffect(e1)
			Duel.BreakEffect()
			Duel.Damage(tp,ct:GetLevel()*300,REASON_EFFECT)
		end
	end
end
