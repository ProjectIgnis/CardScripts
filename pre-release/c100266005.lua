--風化戦士
--Weathering Soldier
--Logical Nonsense

--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--If destroyed by battle, add 1 "Fossil Fusion" or 1 card that specifically lists "Fossil Fusion"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Same as above, but if sent to GY by card effect
	local e2=e1:Clone()
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(s.thcon)
	c:RegisterEffect(e2)
	--Lose 600 ATK during each of your end phases
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1)
	e3:SetCondition(s.atkcon)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
	--Specifically lists itself and "Fossil Fusion"
s.listed_names={id,CARD_FOSSIL_FUSION}

	--Check for "Fossil Fusion" or 1 card that specifically lists "Fossil Fusion"
function s.thfilter(c)
	return c:IsAbleToHand() and not c:IsCode(id)
	 and (c:IsCode(CARD_FOSSIL_FUSION) or aux.IsCodeListed(c,CARD_FOSSIL_FUSION))
end
	--If sent to the GY by card effect
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
	--Activation legality
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
	--Add 1 "Fossil Fusion" or 1 card that specifically lists "Fossil Fusion" from deck to hand
function s.thop(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
	--Check if current phase is player's end phase
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
	--Lose 600 ATK during each of your end phases
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-600)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e1)
end