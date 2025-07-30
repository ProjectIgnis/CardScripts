--ドレミコード・プリモア
--Solfachord Primoria
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--Return 1 "Solfachord" card in your Pendulum Zone to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(function(e,tp,eg) return eg:IsExists(s.pendthconfilter,1,nil,tp) end)
	e1:SetTarget(s.pendthtg)
	e1:SetOperation(s.pendthop)
	c:RegisterEffect(e1)
	--While you have "Solfachord" cards with even and odd Pendulum Scales in your Pendulum Zone, your activated "Solfachord" cards' effects cannot be negated
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_DISEFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.immcon)
	e2:SetValue(s.immval)
	c:RegisterEffect(e2)
	--Add 1 "Solfachord" card from your Deck to your hand, except "Solfachord Primoria"
	local e3a=Effect.CreateEffect(c)
	e3a:SetDescription(aux.Stringid(id,1))
	e3a:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3a:SetProperty(EFFECT_FLAG_DELAY)
	e3a:SetCode(EVENT_SUMMON_SUCCESS)
	e3a:SetCountLimit(1,id)
	e3a:SetTarget(s.deckthtg)
	e3a:SetOperation(s.deckthop)
	c:RegisterEffect(e3a)
	local e3b=e3a:Clone()
	e3b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3b)
	--Add 1 "Solfachord" card from your GY or face-up Extra Deck to your hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(function(e,tp,eg) return eg:IsExists(s.gyedthconfilter,1,nil,tp) end)
	e4:SetTarget(s.gyedthtg)
	e4:SetOperation(s.gyedthop)
	c:RegisterEffect(e4)
end
s.listed_names={id}
s.listed_series={SET_SOLFACHORD}
function s.pendthconfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsPendulumSummoned()
end
function s.pendthfilter(c)
	return c:IsSetCard(SET_SOLFACHORD) and c:IsAbleToHand()
end
function s.pendthtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and s.pendthfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.pendthfilter,tp,LOCATION_PZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.pendthfilter,tp,LOCATION_PZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
end
function s.pendthop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
function s.immcon(e)
	local g=Duel.GetMatchingGroup(Card.IsSetCard,e:GetHandlerPlayer(),LOCATION_PZONE,0,nil,SET_SOLFACHORD)
	local a,b=g:GetFirst(),g:GetNext()
	return a and b and ((a:GetScale()+b:GetScale())%2==1)
end
function s.immval(e,ct)
	local trig_player,trig_setcodes=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_SETCODES)
	if trig_player==1-e:GetHandlerPlayer() then return false end
	for _,setcode in ipairs(trig_setcodes) do
		if (SET_SOLFACHORD&0xfff)==(setcode&0xfff) and (SET_SOLFACHORD&setcode)==SET_SOLFACHORD then return true end
	end
end
function s.deckthfilter(c)
	return c:IsSetCard(SET_SOLFACHORD) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.deckthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.deckthfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.deckthop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.deckthfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.gyedthconfilter(c,tp)
	return c:IsLinkSummoned() and c:IsSetCard(SET_SOLFACHORD) and c:IsSummonPlayer(tp)
end
function s.gyedthfilter(c)
	return c:IsSetCard(SET_SOLFACHORD) and c:IsFaceup() and c:IsAbleToHand()
end
function s.gyedthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.gyedthfilter,tp,LOCATION_GRAVE|LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE|LOCATION_EXTRA)
end
function s.gyedthop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.gyedthfilter),tp,LOCATION_GRAVE|LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end