--魔導雑貨商人
--Magical Merchant
local s,id=GetID()
function s.initial_effect(c)
	--Excavate cards until you find a Spell/Trap
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,LOCATION_DECK,0,nil)
	local dcount=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if dcount==0 then return end
	if #g==0 then
		Duel.ConfirmDecktop(tp,dcount)
		Duel.ShuffleDeck(tp)
		return
	end
	local seq=-1
	local spcard=nil
	for tc in g:Iter() do
		if tc:GetSequence()>seq then
			seq=tc:GetSequence()
			spcard=tc
		end
	end
	Duel.ConfirmDecktop(tp,dcount-seq)
	if spcard:IsAbleToHand() then
		Duel.DisableShuffleCheck()
		Duel.SendtoHand(spcard,nil,REASON_EFFECT)
		Duel.DiscardDeck(tp,dcount-seq-1,REASON_EFFECT|REASON_EXCAVATE)
		Duel.ConfirmCards(1-tp,spcard)
		Duel.ShuffleHand(tp)
	else
		Duel.DiscardDeck(tp,dcount-seq,REASON_EFFECT|REASON_EXCAVATE)
	end
end