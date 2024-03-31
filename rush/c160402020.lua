--燃焼鬼ブンゼル
--Combustion Oni Bunsel
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Send cards from the Decks to the GY and decrease level
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_LVCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,2) and Duel.IsPlayerCanDiscardDeck(1-tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,PLAYER_ALL,2)
end
function s.filter(c)
	return c:IsFaceup() and c:HasLevel() and c:IsLevelBetween(3,8)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.DiscardDeck(tp,2,REASON_EFFECT)>0 and Duel.DiscardDeck(1-tp,2,REASON_EFFECT)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
		local tc=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
		if tc then
			Duel.HintSelection(tc,true)
			local opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))+1
			Duel.BreakEffect()
			tc:UpdateLevel(-opt,RESETS_STANDARD_PHASE_END,e:GetHandler())
		end
	end
end