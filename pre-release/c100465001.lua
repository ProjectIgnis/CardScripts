--黒犬獣バウ
--Bau the Black Dog Beast
--scripted by Naim
local s,id=GetID()
local CARD_STAIRWAY_TO_THE_UNDERWORLD=100465002
local CARD_DOMAIN_OF_THE_DARK_RULER=100465003
function s.initial_effect(c)
	--If this card is Normal or Special Summoned: You can add 1 Level 7 or higher DARK monster with 2500 DEF, 1 "Stairway to the Underworld", or 1 "Domain of the Dark Ruler" from your Deck to your hand
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1a:SetProperty(EFFECT_FLAG_DELAY)
	e1a:SetCode(EVENT_SUMMON_SUCCESS)
	e1a:SetCountLimit(1,{id,0})
	e1a:SetTarget(s.thfromdecktg)
	e1a:SetOperation(s.thfromdeckop)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	--If this card is Tributed or banished: You can target 1 Counter Trap in your GY; add it to your hand
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,1))
	e2a:SetCategory(CATEGORY_TOHAND)
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2a:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2a:SetCode(EVENT_RELEASE)
	e2a:SetCountLimit(1,{id,1})
	e2a:SetTarget(s.thfromgytg)
	e2a:SetOperation(s.thfromgyop)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e2b)
end
s.listed_names={CARD_STAIRWAY_TO_THE_UNDERWORLD,CARD_DOMAIN_OF_THE_DARK_RULER}
function s.thfromdeckfilter(c)
	return ((c:IsLevelAbove(7) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsDefense(2500))
		or (c:IsCode(CARD_STAIRWAY_TO_THE_UNDERWORLD,CARD_DOMAIN_OF_THE_DARK_RULER)))
		and c:IsAbleToHand()
end
function s.thfromdecktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfromdeckfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thfromdeckop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfromdeckfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.thfromgyfilter(c)
	return c:IsCounterTrap() and c:IsAbleToHand()
end
function s.thfromgytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfromgyfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfromgyfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfromgyfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
end
function s.thfromgyop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end