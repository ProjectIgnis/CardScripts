--カードスキャナー
--Card Scanner
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Reveal the bottom card of the decks
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.decltg)
	e2:SetOperation(s.declop)
	c:RegisterEffect(e2)
	--Make the opponent place 1 card on the bottom of the Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(s.tdcond)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end
function s.decltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
		and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPTION)
	local op=Duel.SelectOption(tp,DECLTYPE_MONSTER,DECLTYPE_SPELL,DECLTYPE_TRAP)
	e:SetLabel(op)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,PLAYER_ALL,LOCATION_DECK)
end
function s.declop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 or Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)==0 then return end
	local label=e:GetLabel()
	local decl_type=(label==0 and TYPE_MONSTER)
		or (label==1 and TYPE_SPELL)
		or (label==2 and TYPE_TRAP)
	local c1=Duel.GetDeckbottomGroup(tp,1):GetFirst()
	local c2=Duel.GetDeckbottomGroup(1-tp,1):GetFirst()
	Duel.ConfirmCards(1-tp,c1)
	Duel.ConfirmCards(tp,c2)
	Duel.DisableShuffleCheck()
	if c1 then
		if c1:IsType(decl_type) and c1:IsAbleToHand() then
			Duel.SendtoHand(c1,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,c1)
			Duel.ShuffleHand(tp)
		else
			Duel.MoveSequence(c1,SEQ_DECKTOP)
			Duel.ConfirmDecktop(tp,1)
		end
	end
	if c2 then
		if c2:IsType(decl_type) and c2:IsAbleToHand() then
			Duel.SendtoHand(c2,nil,REASON_EFFECT)
			Duel.ConfirmCards(tp,c2)
			Duel.ShuffleHand(1-tp)
		else
			Duel.MoveSequence(c2,SEQ_DECKTOP)
			Duel.ConfirmDecktop(1-tp,1)
		end
	end
end
function s.tdcond(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_STZONE) and c:IsPreviousPosition(POS_FACEUP)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_HAND,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_HAND)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(1-tp,Card.IsAbleToDeck,1-tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_RULE,1-tp)
	end
end