--罪宝合戦
--Sinful Spoils Struggle
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Target any number of cards on the field (the max. number of targets on each side is the number of that player's "Sinful Spoils" cards that are banished or in their GY); destroy them
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--If this Set card is destroyed or banished by your opponent's activated effect: You can shuffle up to 2 cards from the field into the Deck
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,1))
	e2a:SetCategory(CATEGORY_TODECK)
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2a:SetProperty(EFFECT_FLAG_DELAY)
	e2a:SetCode(EVENT_DESTROYED)
	e2a:SetCondition(s.tdcon)
	e2a:SetTarget(s.tdtg)
	e2a:SetOperation(s.tdop)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e2b)
end
s.listed_series={SET_SINFUL_SPOILS}
function s.desrescon(max0,max1)
	return function(sg,e,tp,mg)
		local ct0=sg:FilterCount(Card.IsControler,nil,tp)
		local res=ct0<=max0 and (#sg-ct0)<=max1
		return res,not res
	end
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	local ct0=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,SET_SINFUL_SPOILS),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
	local ct1=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,SET_SINFUL_SPOILS),tp,0,LOCATION_GRAVE|LOCATION_REMOVED,nil)
	local g0=Duel.GetTargetGroup(nil,tp,LOCATION_ONFIELD,0,e:GetHandler())
	local g1=Duel.GetTargetGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return (#g0>0 and ct0>0) or (#g1>0 and ct1>0) end
	local tg=aux.SelectUnselectGroup(g0+g1,e,tp,1,ct0+ct1,s.desrescon(ct0,ct1),1,tp,HINTMSG_DESTROY)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,#tg,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEDOWN) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
		and rp==1-tp and re and re:IsActivated() and c:IsReason(REASON_EFFECT)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,PLAYER_EITHER,LOCATION_ONFIELD)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end