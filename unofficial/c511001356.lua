--ヒーローズ・ギルド
--Hero's Guild
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--send to grave
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DECKDES+CATEGORY_TOHAND+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) and Duel.IsPlayerCanDiscardDeck(1-tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,PLAYER_ALL,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or not Duel.IsPlayerCanDiscardDeck(tp,1)
		or not Duel.IsPlayerCanDiscardDeck(1-tp,1) then return end
	local tc1=Duel.GetDecktopGroup(tp,1):GetFirst()
	local tc2=Duel.GetDecktopGroup(1-tp,1):GetFirst()
	Duel.DiscardDeck(tp,1,REASON_EFFECT)
	Duel.DiscardDeck(1-tp,1,REASON_EFFECT)
	local toHand=false
	if tc1 and tc1:IsRace(RACE_WARRIOR) and tc1:IsLocation(LOCATION_GRAVE)
		and tc1:IsAbleToHand() and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.SendtoHand(tc1,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc1)
		toHand=true
	end
	if tc2 and tc2:IsRace(RACE_WARRIOR) and tc2:IsLocation(LOCATION_GRAVE)
		and tc2:IsAbleToHand() and Duel.SelectYesNo(1-tp,aux.Stringid(id,0)) then
		Duel.SendtoHand(tc2,nil,REASON_EFFECT)
		Duel.ConfirmCards(tp,tc2)
		toHand=true
	end
	if toHand then
		Duel.Destroy(e:GetHandler(s),REASON_EFFECT)
	end
end