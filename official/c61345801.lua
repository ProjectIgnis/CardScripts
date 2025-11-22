--煉獄の乖放
--Void Liberation
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Add 2 "Shaddoll" cards from your Deck to your hand of different types (Monster, Spell, or Trap) from the revealed card and each other, then discard 1 card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(Cost.Reveal(s.revealfilter,true,1,1,function(e,tp,g) e:SetLabel(g:GetFirst():GetMainCardType()) end))
	e1:SetTarget(s.shaddollthtg)
	e1:SetOperation(s.shaddollthop)
	c:RegisterEffect(e1)
	--Add 1 "Infernoid" monster from your Deck or GY your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.infernoidthtg)
	e2:SetOperation(s.infernoidthop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SHADDOLL,SET_INFERNOID}
function s.revealfilter(c,e,tp)
	return c:IsSetCard(SET_SHADDOLL) and not c:IsPublic()
		and Duel.GetMatchingGroup(s.shaddollthfilter,tp,LOCATION_DECK,0,nil,c:GetMainCardType()):GetClassCount(Card.GetMainCardType)==2
end
function s.shaddollthfilter(c,main_type)
	return c:IsSetCard(SET_SHADDOLL) and c:IsAbleToHand() and not c:IsType(main_type)
end
function s.shaddollthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.shaddollthop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.shaddollthfilter,tp,LOCATION_DECK,0,nil,e:GetLabel())
	if #g<2 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dpcheck(Card.GetMainCardType),1,tp,HINTMSG_ATOHAND)
	if #sg==2 and Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,sg)
		Duel.ShuffleHand(tp)
		Duel.BreakEffect()
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT|REASON_DISCARD,nil)
	end
end
function s.infernoidthfilter(c)
	return c:IsSetCard(SET_INFERNOID) and c:IsMonster() and c:IsAbleToHand()
end
function s.infernoidthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.infernoidthfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.infernoidthop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.infernoidthfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end