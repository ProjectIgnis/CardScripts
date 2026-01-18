--キラーチューン・ロタリー
--Kewl Tune Rotary
--scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--If this card on the field would be used as Synchro Material, 1 Tuner in your hand can be used as 1 of the other materials
	Synchro.AddHandMaterialEffect(c,id,function(c) return c:IsType(TYPE_TUNER) end)
	--You can reveal this card and 1 other Tuner in your hand; immediately after this effect resolves, Normal Summon 1 Tuner
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(s.nscost)
	e1:SetTarget(s.nstg)
	e1:SetOperation(s.nsop)
	c:RegisterEffect(e1)
	--If this card is sent to the GY as Synchro Material: You can activate 1 of these effects;
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO end)
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_KEWL_TUNE}
function s.nscostfilter(c)
	return c:IsType(TYPE_TUNER) and not c:IsPublic()
end
function s.nscost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() and Duel.IsExistingMatchingCard(s.nscostfilter,tp,LOCATION_HAND,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local rc=Duel.SelectMatchingCard(tp,s.nscostfilter,tp,LOCATION_HAND,0,1,1,c):GetFirst()
	Duel.ConfirmCards(1-tp,Group.FromCards(c,rc))
	Duel.ShuffleHand(tp)
end
function s.nsfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsSummonable(true,nil)
end
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.nsfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_MZONE)
end
function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.nsfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil):GetFirst()
	if sc then
		Duel.Summon(tp,sc,true,nil)
	end
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,nil)
	local b2=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_TODECK)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_GRAVE)
	elseif op==2 then
		e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end
function s.thfilter(c)
	return c:IsSetCard(SET_KEWL_TUNE) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--● Place 1 card from your opponent's GY on the bottom of the Deck
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end		
	elseif op==2 then
		--● Look at your opponent's hand, then you can add 1 "Kewl Tune" Spell/Trap from your Deck to your hand
		local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		if #g==0 then return end
		Duel.ConfirmCards(tp,g)
		Duel.ShuffleHand(1-tp)
		local hg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
		if #hg==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,4)) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local hsg=hg:Select(tp,1,1,nil)
		if #hsg>0 then
			Duel.BreakEffect()
			Duel.SendtoHand(hsg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,hsg)
		end
	end
end