-- 迷犬メリー
-- Outstanding Dog Mary
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Place to bottom or search and place to top
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
end
s.listed_names={11548522}
function s.thfilter(c)
	return c:IsCode(11548522) and c:IsAbleToHand()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() end
	local op=Duel.SelectEffect(tp,
		{true,aux.Stringid(id,0)},
		{Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil),aux.Stringid(id,1)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_TODECK)
	else
		e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_TODECK)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,tp,LOCATION_GRAVE)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	if op==1 and c:IsRelateToEffect(e) then
		Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	elseif op==2 then
		Duel.DisableShuffleCheck(true)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
			Duel.ConfirmCards(1-tp,g)
			Duel.ShuffleDeck(tp)
			if c:IsRelateToEffect(e) then
				Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)
			end
		end
	end
end
