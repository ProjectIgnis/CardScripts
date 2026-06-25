--三幻魔解放
--Unleashing the Sacred Beasts
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Add 3 "Sacred Beast" monsters with different names from your Deck to your hand, then discard 2 cards
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.th3tg)
	e1:SetOperation(s.th3op)
	c:RegisterEffect(e1)
	--If this card is in your GY, except the turn it was sent there: You can banish it; add 1 Level 10 Pyro, Thunder, or Fiend monster that cannot be Normal Summoned/Set from your Deck to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(aux.exccon)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.th1tg)
	e2:SetOperation(s.th1op)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SACRED_BEAST}
function s.th3filter(c)
	return c:IsSetCard(SET_SACRED_BEAST) and c:IsMonster() and c:IsAbleToHand()
end
function s.th3tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		local g=Duel.GetMatchingGroup(s.th3filter,tp,LOCATION_DECK,0,nil)
		return aux.SelectUnselectGroup(g,e,tp,3,3,aux.dncheck,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,3,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,2)
end
function s.th3op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.th3filter,tp,LOCATION_DECK,0,nil)
	if #g<3 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,3,3,aux.dncheck,1,tp,HINTMSG_ATOHAND)
	if #sg==3 and Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,sg)
		Duel.ShuffleHand(tp)
		Duel.BreakEffect()
		Duel.DiscardHand(tp,nil,2,2,REASON_EFFECT|REASON_DISCARD,nil)
	end
end
function s.th1filter(c)
	return c:IsLevel(10) and c:IsRace(RACE_PYRO|RACE_THUNDER|RACE_FIEND) and not c:IsSummonableCard()
		and c:IsAbleToHand()
end
function s.th1tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.th1filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.th1op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.th1filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
	end
end