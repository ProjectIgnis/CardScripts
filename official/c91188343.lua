--神秘の代行者 アース
--The Agent of Mystery - Earth
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 "The Agent" monster from your Deck to your hand, except "The Agent of Mystery - Earth", or if "The Sanctuary in the Sky" is on the field, you can add 1 "Master Hyperion" instead
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_THE_AGENT}
s.listed_names={id,CARD_SANCTUARY_SKY,55794644} --"Master Hyperion"
function s.thilter(c,sanct_chk)
	return ((c:IsSetCard(SET_THE_AGENT) and c:IsMonster() and not c:IsCode(id)) or (sanct_chk and c:IsCode(55794644))) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local sanct_chk=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_SANCTUARY_SKY),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) or Duel.IsEnvironment(CARD_SANCTUARY_SKY)
		return Duel.IsExistingMatchingCard(s.thilter,tp,LOCATION_DECK,0,1,nil,sanct_chk)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local sanct_chk=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_SANCTUARY_SKY),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) or Duel.IsEnvironment(CARD_SANCTUARY_SKY)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thilter,tp,LOCATION_DECK,0,1,1,nil,sanct_chk)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end