--糾罪巧β’－「ａｌａｚｏｎｅＩＡ」
--Enneacraft β' "alazoneIA"
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_SINQUISITION,LOCATION_PZONE)
	Pendulum.AddProcedure(c)
	--Each time a monster(s) is flipped face-up, place 1 Sinquisition Counter on this card
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_FLIP)
	e1:SetRange(LOCATION_PZONE)
	e1:SetOperation(s.counterop)
	c:RegisterEffect(e1)
	--Reveal 3 "Enneacraft" cards from your Deck, your opponent randomly picks 1 for you to add to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(Cost.PayLP(900))
	e2:SetTarget(s.rvtg)
	e2:SetOperation(s.rvop)
	c:RegisterEffect(e2)
	--Special Summon 1 monster from your hand in face-down Defense Position
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND)
	e3:SetCost(Cost.AND(Cost.SelfReveal,s.spcost))
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,function(c) return c:IsPosition(POS_FACEDOWN_DEFENSE) end)
	--Add 1 "Enneacraft" card from your Deck to your hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.thcon)
	e4:SetCost(Cost.SelfChangePosition(POS_FACEUP_DEFENSE))
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
	--Banish 1 random card from your opponent's hand face-up until the End Phase
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,3))
	e5:SetCategory(CATEGORY_REMOVE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_FLIP)
	e5:SetTarget(s.rmtg)
	e5:SetOperation(s.rmop)
	c:RegisterEffect(e5)
end
s.counter_place_list={COUNTER_SINQUISITION}
s.listed_series={SET_ENNEACRAFT}
function s.counterop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.IsChainSolving() then
		c:AddCounter(COUNTER_SINQUISITION,1)
	else
		--Place 1 Sinquisition Counter on this card at the end of the Chain Link
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_SOLVED)
		e1:SetRange(LOCATION_PZONE)
		e1:SetOperation(function() c:AddCounter(COUNTER_SINQUISITION,1) end)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_CHAIN)
		c:RegisterEffect(e1)
		--Reset "e1" at the end of the Chain Link
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAIN_SOLVED)
		e2:SetOperation(function() e1:Reset() end)
		e2:SetReset(RESET_CHAIN)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.rvfilter(c)
	return c:IsSetCard(SET_ENNEACRAFT) and c:IsAbleToHand() and not c:IsPublic()
end
function s.rvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rvfilter,tp,LOCATION_DECK,0,3,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.rvop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.rvfilter,tp,LOCATION_DECK,0,3,3,nil)
	if #g~=3 then return end
	Duel.ConfirmCards(1-tp,g)
	local sg=g:RandomSelect(1-tp,1)
	if #sg>0 then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
	Duel.ShuffleDeck(tp)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	--You cannot Special Summon the turn you activate this effect, except in face-down Defense Position
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,4))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_FORCE_SPSUMMON_POSITION)
	e1:SetTargetRange(1,0)
	e1:SetValue(POS_FACEDOWN_DEFENSE)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(Card.IsCanBeSpecialSummoned,tp,LOCATION_HAND,0,1,nil,e,0,tp,false,false,POS_FACEDOWN_DEFENSE) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,Card.IsCanBeSpecialSummoned,tp,LOCATION_HAND,0,1,1,nil,e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
	end
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return false end
	if re:IsHasCategory(CATEGORY_SEARCH) or re:IsHasCategory(CATEGORY_DRAW) then return true end
	local ex1,g1,gc1,dp1,loc1=Duel.GetOperationInfo(ev,CATEGORY_TOHAND)
	local ex2,g2,gc2,dp2,loc2=Duel.GetPossibleOperationInfo(ev,CATEGORY_TOHAND)
	local g=Group.CreateGroup()
	if g1 then g:Merge(g1) end
	if g2 then g:Merge(g2) end
	return (((loc1 or 0)|(loc2 or 0))&LOCATION_DECK)>0 or (#g>0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK))
end
function s.thfilter(c)
	return c:IsSetCard(SET_ENNEACRAFT) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil)
	if #g==0 then return end
	local rg=g:RandomSelect(tp,1)
	if #rg>0 then
		--Banish 1 random card from your opponent's hand face-up until the End Phase
		aux.RemoveUntil(rg,POS_FACEUP,REASON_EFFECT|REASON_TEMPORARY,PHASE_END,id,e,tp,function(ag,e,tp) Duel.SendtoHand(ag,nil,REASON_EFFECT) end)
	end
end