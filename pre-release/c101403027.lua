--リインゼルム・ギガロヴェンドラ
--Reindsurm Gigalovendra
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--(Quick Effect): You can send 2 cards from your hand to the GY, including this card; add 1 non-FIRE "Reindsurm" monster from your Deck to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(s.deckthcost)
	e1:SetTarget(s.deckthtg)
	e1:SetOperation(s.deckthop)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--If this card is Ritual Summoned, or your opponent Special Summons a monster(s): You can shuffle up to 2 monsters on the field into the Deck
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,1))
	e2a:SetCategory(CATEGORY_TODECK)
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2a:SetProperty(EFFECT_FLAG_DELAY)
	e2a:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2a:SetCountLimit(1,{id,1})
	e2a:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():IsRitualSummoned()
	end)
	e2a:SetTarget(s.tdtg)
	e2a:SetOperation(s.tdop)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2b:SetRange(LOCATION_MZONE)
	e2b:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
	end)
	c:RegisterEffect(e2b)
	--If this card and a WATER "Reindsurm" monster are in your GY: You can add this card to your hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.selfthcon)
	e3:SetTarget(s.selfthtg)
	e3:SetOperation(s.selfthop)
	c:RegisterEffect(e3)
end
s.listed_names={101403055} --"Reindsurm Conquest"
s.listed_series={SET_REINDSURM}
function s.deckthcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,c) end
	local sg=Group.FromCards(c)
	local g=Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,c)
	while #sg<2 do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sc=Group.SelectUnselect(g,sg,tp,false,false,2,2)
		if not sg:IsContains(sc) then
			sg:AddCard(sc)
			g:RemoveCard(sc)
		elseif sc~=c then
			sg:RemoveCard(sc)
			g:AddCard(sc)
		end
	end
	Duel.SendtoGrave(sg,REASON_COST)
end
function s.deckthfilter(c)
	return c:IsAttributeExcept(ATTRIBUTE_FIRE) and c:IsSetCard(SET_REINDSURM) and c:IsMonster() and c:IsAbleToHand()
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
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,PLAYER_EITHER,LOCATION_MZONE)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,1,2,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
function s.selfthconfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsSetCard(SET_REINDSURM)
end
function s.selfthcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.selfthconfilter,tp,LOCATION_GRAVE,0,1,nil)
end
function s.selfthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
end
function s.selfthop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end