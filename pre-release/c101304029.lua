--道化の一座 フレア
--Clown Crew Flare
--scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--You can reveal this card in your hand; add 1 non-Ritual "Clown Crew" card from your Deck to your hand, then discard 1 card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.SelfReveal)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--If this card is Tributed: You can activate 1 of these effects (but you can only use each of these effects of "Clown Crew Flare" once per turn)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_RELEASE)
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_CLOWN_CREW}
function s.thfilter(c)
	return c:IsSetCard(SET_CLOWN_CREW) and not c:IsRitualMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		Duel.BreakEffect()
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT|REASON_DISCARD,nil)
	end
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=not Duel.HasFlagEffect(tp,id)
		and Duel.IsExistingMatchingCard(aux.AND(Card.IsRitualMonster,Card.IsFaceup,Card.IsAbleToDeck),tp,LOCATION_MZONE|LOCATION_GRAVE,LOCATION_MZONE|LOCATION_GRAVE,1,nil)
	local b2=not Duel.HasFlagEffect(tp,id+100)
		and Duel.IsExistingMatchingCard(aux.AND(Card.IsEffectMonster,Card.IsCanTurnSet),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		e:SetCategory(CATEGORY_TODECK)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,PLAYER_ALL,LOCATION_MZONE|LOCATION_GRAVE)
	elseif op==2 then
		Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE|PHASE_END,0,1)
		e:SetCategory(CATEGORY_POSITION)
		Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,PLAYER_EITHER,POS_FACEDOWN_DEFENSE)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--● Shuffle all Ritual Monsters on the field and in the GYs into the Deck
		local g=Duel.GetMatchingGroup(aux.AND(Card.IsRitualMonster,Card.IsFaceup,Card.IsAbleToDeck),tp,LOCATION_MZONE|LOCATION_GRAVE,LOCATION_MZONE|LOCATION_GRAVE,nil)
		if #g>0 then
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	elseif op==2 then
		--● Change 1 Effect Monster on the field to face-down Defense Position
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
		local g=Duel.SelectMatchingCard(tp,aux.AND(Card.IsEffectMonster,Card.IsCanTurnSet),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
		end
	end
end