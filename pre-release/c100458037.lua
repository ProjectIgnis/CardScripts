--狂嵐異解△プルートニオン
--Mad Tempest Xenovader△ Ploutonion
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--(Quick Effect): You can reveal this card and 1 other "Xenovader△" card in your hand; banish both (face-down), and if you do, draw 2 cards. You can only use this effect of "Mad Tempest Xenovader△ Ploutonion" once per turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.selfbancost)
	e1:SetTarget(s.selfbantg)
	e1:SetOperation(s.selfbanop)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--If this card is Normal or Special Summoned: Banish (face-down) the top 7 cards of your Deck
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,1))
	e2a:SetCategory(CATEGORY_REMOVE)
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2a:SetCode(EVENT_SUMMON_SUCCESS)
	e2a:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return true end
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,7,tp,LOCATION_DECK)
	end)
	e2a:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local g=Duel.GetDecktopGroup(tp,7)
		if #g>0 then
			Duel.DisableShuffleCheck()
			Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
		end
	end)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2b)
	--Once per turn (Quick Effect): You can shuffle 1 of your face-down banished "Xenovader△" monsters into the Deck, then you can shuffle 1 monster your opponent controls with the same Attribute into the Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	e3:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e3)
end
s.listed_series={SET_XENOVADER}
function s.selfbancostfilter(c,tp)
	return c:IsSetCard(SET_XENOVADER) and not c:IsPublic() and c:IsAbleToRemove(tp,POS_FACEDOWN)
end
function s.selfbancost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() and Duel.IsExistingMatchingCard(s.selfbancostfilter,tp,LOCATION_HAND,0,1,c,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local sc=Duel.SelectMatchingCard(tp,s.selfbancostfilter,tp,LOCATION_HAND,0,1,1,c,tp):GetFirst()
	local g=Group.FromCards(c,sc)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
	sc:CreateEffectRelation(e)
	e:GetChainData().revealed_cards=g
end
function s.selfbantg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove(tp,POS_FACEDOWN)
		and Duel.IsPlayerCanDraw(tp,2) end
	local revealed_cards=e:GetChainData().revealed_cards
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,revealed_cards,2,tp,POS_FACEDOWN)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.selfbanop(e,tp,eg,ep,ev,re,r,rp)
	local revealed_cards=e:GetChainData().revealed_cards:Match(Card.IsRelateToEffect,nil,e)
	if #revealed_cards==2 and Duel.Remove(revealed_cards,POS_FACEDOWN,REASON_EFFECT)==2 and revealed_cards:FilterCount(Card.IsLocation,nil,LOCATION_REMOVED)==2 then
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
function s.tdfilter(c)
	return c:IsFacedown() and c:IsSetCard(SET_XENOVADER) and c:IsMonster() and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_REMOVED)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_MZONE)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sc=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_REMOVED,0,1,1,nil):GetFirst()
	if not sc then return end
	Duel.ConfirmCards(1-tp,sc)
	if Duel.SendtoDeck(sc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_DECK|LOCATION_EXTRA)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsAttribute,sc:GetAttribute()),tp,0,LOCATION_MZONE,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsAttribute,sc:GetAttribute()),tp,0,LOCATION_MZONE,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.BreakEffect()
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end