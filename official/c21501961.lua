--恐依のペアルックマ！！
--Pair Bear Scare!!
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Your opponent can reveal 1 "Pair Bear Scare!!" in their hand or Deck, and if they do, each player gains 2000 LP, otherwise, you destroy 1 monster your opponent controls
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--Add this card to your opponent's hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_DUEL)
	e2:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) end)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_RECOVER,nil,0,PLAYER_ALL,2000)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_MZONE)
end
function s.revealfilter(c)
	return c:IsCode(id) and not c:IsPublic()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local opp=1-tp
	if Duel.IsExistingMatchingCard(s.revealfilter,opp,LOCATION_HAND|LOCATION_DECK,0,1,nil)
		and Duel.SelectYesNo(opp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,opp,HINTMSG_CONFIRM)
		local sc=Duel.SelectMatchingCard(opp,s.revealfilter,opp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil):GetFirst()
		Duel.ConfirmCards(tp,sc)
		if sc:IsLocation(LOCATION_HAND) then
			Duel.ShuffleHand(opp)
		else
			Duel.ShuffleDeck(opp)
		end
		Duel.Recover(tp,2000,REASON_EFFECT)
		Duel.Recover(opp,2000,REASON_EFFECT)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,tp,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,1-tp,REASON_EFFECT)
	end
end