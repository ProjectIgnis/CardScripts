--未来への沈黙
--Future Silence
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_BATTLE_START|TIMING_BATTLE_END|TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_SHINING_SARCOPHAGUS}
function s.thfilter(c)
	return c:IsMonster() and c:ListsCode(CARD_SHINING_SARCOPHAGUS) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct1=6-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	local ct2=6-Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	local draw=Duel.IsBattlePhase() and e:IsHasType(EFFECT_TYPE_ACTIVATE)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_SHINING_SARCOPHAGUS),tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.ListsCode,CARD_SHINING_SARCOPHAGUS),tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		and (not draw or (ct1>0 and Duel.IsPlayerCanDraw(tp,ct1)
		and ct2>0 and Duel.IsPlayerCanDraw(1-tp,ct2))) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	if draw then
		e:SetLabel(1)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct1)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,ct2)
	else
		e:SetLabel(0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g==0 or Duel.SendtoHand(g,nil,REASON_EFFECT)==0 then return end
	Duel.ConfirmCards(1-tp,g)
	if e:GetLabel()==0 then return end
	Duel.ShuffleHand(tp)
	Duel.ShuffleDeck(tp)
	local turn_p=Duel.GetTurnPlayer()
	local ct1=6-Duel.GetFieldGroupCount(turn_p,LOCATION_HAND,0)
	local ct2=6-Duel.GetFieldGroupCount(turn_p,0,LOCATION_HAND)
	if ct1>0 or ct2>0 then Duel.BreakEffect() end
	if ct1>0 then
		Duel.Draw(turn_p,ct1,REASON_EFFECT)
	end
	if ct2>0 then
		Duel.Draw(1-turn_p,ct2,REASON_EFFECT)
	end
end