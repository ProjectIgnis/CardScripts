--破械断獄
--Conviction of the Unchained
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Target up to 2 Spells/Traps on the field, including a card you control; destroy them, then if you destroyed a face-down card, you can send 1 "Unchained" monster from your Deck to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--If this card on the field is destroyed by an "Unchained" card's effect: You can Special Summon 1 Level 8 "Unchained" monster from your Deck, then you can shuffle 1 card each from both your hand and your opponent's GY into the Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and re:IsCardSetcode(SET_UNCHAINED)
	end)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_UNCHAINED}
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsControler,1,nil,tp)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsSpellTrap() and chkc:IsOnField() and chkc~=c end
	if chk==0 then return Duel.IsExistingTarget(Card.IsSpellTrap,tp,LOCATION_ONFIELD,0,1,c) end
	local g=Duel.GetTargetGroup(Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	local tg=aux.SelectUnselectGroup(g,e,tp,1,2,s.rescon,1,tp,HINTMSG_DESTROY)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,#tg,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgfilter(c)
	return c:IsSetCard(SET_UNCHAINED) and c:IsMonster() and c:IsAbleToGrave()
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 and Duel.Destroy(tg,REASON_EFFECT)>0 and Duel.GetOperatedGroup():IsExists(Card.IsPreviousPosition,1,nil,POS_FACEDOWN)
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.BreakEffect()
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
function s.spfilter(c,e,tp)
	return c:IsLevel(8) and c:IsSetCard(SET_UNCHAINED) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,2,PLAYER_ALL,LOCATION_HAND|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,nil)
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(Card.IsAbleToDeck),tp,0,LOCATION_GRAVE,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAbleToDeck),tp,LOCATION_HAND,LOCATION_GRAVE,nil)
		local sg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dpcheck(Card.GetControler),1,tp,HINTMSG_TODECK)
		if #sg==2 then
			Duel.HintSelection(sg)
			Duel.BreakEffect()
			Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end