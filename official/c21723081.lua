--Ｘ・Ｙ・Ｚハイパーキャノン
--XYZ Hyper Cannon
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Activate the appropriate effect based on whose turn it is
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCondition(s.effcon)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.listed_card={91998119} --"XYZ-Dragon Cannon"
s.listed_card_types={TYPE_UNION}
function s.effconfilter(c)
	return (c:IsCode(91998119) or (c:IsType(TYPE_FUSION) and c:IsMonster() and c:ListsCodeAsMaterial(91998119))) and c:IsFaceup()
end
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.effconfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.tdfilter(c)
	return c:IsType(TYPE_UNION) and c:IsFaceup() and c:IsAbleToDeck()
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local op=e:GetLabel()
		if op==1 then
			return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.tdfilter(chkc)
		elseif op==2 then
			return chkc:IsOnField() and chkc:IsControler(1-tp)
		end
	end
	local b1=Duel.IsTurnPlayer(tp) and Duel.IsPlayerCanDraw(tp,1)
		and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_REMOVED,0,1,nil)
	local b2=Duel.IsTurnPlayer(1-tp)
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler())
		and Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil)
	if chk==0 then return b1 or b2 end
	local op=b1 and 1 or 2
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_REMOVED,0,1,1,nil)
		Duel.SetTargetPlayer(tp)
		Duel.SetTargetParam(1)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,tp,0)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	elseif op==2 then
		e:SetCategory(CATEGORY_DESTROY)
		local target_ct=Duel.GetTargetCount(nil,tp,0,LOCATION_ONFIELD,nil)
		local discard_ct=Duel.DiscardHand(tp,Card.IsDiscardable,1,target_ct,REASON_COST|REASON_DISCARD)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,discard_ct,discard_ct,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,discard_ct,tp,0)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Place 1 of your banished Union monsters on the bottom of your Deck, and if you do, draw 1 card
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_DECK|LOCATION_EXTRA) then
			local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
			Duel.Draw(p,d,REASON_EFFECT)
		end
	elseif op==2 then
		--Destroy cards your opponent controls equal to the number of cards you discarded
		local tg=Duel.GetTargetCards(e)
		if #tg>0 then
			Duel.Destroy(tg,REASON_EFFECT)
		end
	end
end