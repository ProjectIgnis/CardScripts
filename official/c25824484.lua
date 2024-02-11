--森羅の仙樹 レギア
--Sylvan Hermitree
local s,id=GetID()
function s.initial_effect(c)
	--Excavate the top card of your Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Sort up to 3 cards from the top of your Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(s.sdcon)
	e2:SetOperation(s.sdop)
	c:RegisterEffect(e2)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	Duel.ConfirmDecktop(tp,1)
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	if tc:IsRace(RACE_PLANT) then
		Duel.DisableShuffleCheck()
		Duel.SendtoGrave(tc,REASON_EFFECT|REASON_EXCAVATE)
		local ccount=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
		if ccount>0 then
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	else
		Duel.MoveToDeckBottom(tc)
	end
end
function s.sdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsReason(REASON_EXCAVATE)
end
function s.sdop(e,tp,eg,ep,ev,re,r,rp)
	local ct=math.min(Duel.GetFieldGroupCount(tp,LOCATION_DECK,0),3)
	if ct==0 then return end
	local ac=ct==1 and ct or Duel.AnnounceNumberRange(tp,1,ct)
	Duel.SortDecktop(tp,tp,ac)
end