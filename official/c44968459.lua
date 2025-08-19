--サイレント・バーニング
--Silent Burning
local s,id=GetID()
function s.initial_effect(c)
	--Each player draws until they have 6 cards in their hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(TIMING_BATTLE_PHASE,TIMING_BATTLE_START|TIMING_BATTLE_PHASE|TIMING_BATTLE_STEP_END|TIMING_BATTLE_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e1)
	--Add 1 "Silent Magician" monster from your Deck to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SILENT_MAGICIAN}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsBattlePhase() and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_SILENT_MAGICIAN),tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct1=6-Duel.GetMatchingGroupCount(nil,tp,LOCATION_HAND,0,e:GetHandler())
	local ct2=6-Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	if chk==0 then return ct1>0 and Duel.IsPlayerCanDraw(tp,ct1)
		and ct2>0 and Duel.IsPlayerCanDraw(1-tp,ct2) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,ct1+ct2)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local turn_player=Duel.GetTurnPlayer()
	local ct1=6-Duel.GetFieldGroupCount(turn_player,LOCATION_HAND,0)
	local ct2=6-Duel.GetFieldGroupCount(turn_player,0,LOCATION_HAND)
	if ct1>0 then
		Duel.Draw(turn_player,ct1,REASON_EFFECT)
	end
	if ct2>0 then
		Duel.Draw(1-turn_player,ct2,REASON_EFFECT)
	end
end
function s.thfilter(c)
	return c:IsSetCard(SET_SILENT_MAGICIAN) and c:IsMonster() and c:IsAbleToHand()
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