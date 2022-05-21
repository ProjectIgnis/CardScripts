-- 古衛兵アギド
-- Agido the Ancient Sentry
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- Mill 5 cards from each Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_DECK) end)
	e2:SetTarget(s.mltg)
	e2:SetOperation(s.mlop)
	c:RegisterEffect(e2)
end
s.listed_names={id,CARD_EXCHANGE_SPIRIT}
function s.spconfilter(c,tp)
	return c:IsControler(1-tp) and c:IsPreviousLocation(LOCATION_HAND+LOCATION_DECK)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spconfilter,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_FAIRY) and c:IsLevel(4)
		and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.BreakEffect()
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function s.mltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,5) and Duel.IsPlayerCanDiscardDeck(1-tp,5) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,PLAYER_ALL,5)
end
function s.mlop(e,tp,eg,ep,ev,re,r,rp)
	if (Duel.DiscardDeck(tp,5,REASON_EFFECT)+Duel.DiscardDeck(1-tp,5,REASON_EFFECT))<=0
		or not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,CARD_EXCHANGE_SPIRIT) then return end
	local b1=Duel.IsPlayerCanDiscardDeck(tp,5)
	local b2=Duel.IsPlayerCanDiscardDeck(1-tp,5)
	if (b1 or b2) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		local op=aux.SelectEffect(tp,
			{b1,aux.Stringid(id,4)},
			{b2,aux.Stringid(id,5)})
		Duel.DiscardDeck(op==1 and tp or 1-tp,5,REASON_EFFECT)
	end
end