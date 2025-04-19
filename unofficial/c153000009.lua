--機械軍曹機械軍曹
--Robotic Knight (Deck Master)
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	if not DeckMaster then
		return
	end
	--Deck Master Effect
	local dme1=Effect.CreateEffect(c)
	dme1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	dme1:SetCode(EVENT_FREE_CHAIN)
	dme1:SetCondition(s.con)
	dme1:SetOperation(s.op)
	local dme2=dme1:Clone()
	dme2:SetCode(EVENT_CHAIN_END)
	DeckMaster.RegisterAbilities(c,dme1,dme2)
end
function s.costfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsDiscardable(REASON_EFFECT)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) and Duel.IsDeckMaster(tp,id)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Hint(HINT_CARD,1-tp,id)
	local ct=Duel.DiscardHand(tp,s.costfilter,1,99,REASON_EFFECT+REASON_DISCARD)
	if ct>0 then
		Duel.Damage(1-tp,ct*500,REASON_EFFECT)
	end
end