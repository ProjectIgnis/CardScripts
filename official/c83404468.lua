--一色万骨
--The Toil of the Normal
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Apply these effects in sequence, based on the number of Normal Monsters with different names in your GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE+CATEGORY_TODECK+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.listed_names={id}
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_NORMAL) end
	local ct=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_NORMAL):GetClassCount(Card.GetCode)
	if ct>=1 then
		Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,nil,0,tp,800)
	end
	if ct>=2 then
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,tp,LOCATION_MZONE)
	end
	if ct>=4 then
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_MZONE)
	end
	if ct>=5 then
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_ATKCHANGE,nil,0,tp,800)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DISABLE,nil,1,tp,LOCATION_MZONE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_MZONE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.disfilter(c)
	return c:IsNegatableMonster() and c:IsType(TYPE_EFFECT)
end
function s.tdfilter(c)
	return c:IsType(TYPE_EFFECT) and c:IsFaceup() and c:IsAbleToDeck()
end
function s.thfilter(c)
	return c:IsCode(id) and c:IsAbleToHand()
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_NORMAL):GetClassCount(Card.GetCode)
	if ct==0 then return end
	local c=e:GetHandler()
	local breakeff=false
	if ct>=1 then
		--● 1+: This turn, Normal Monsters you control gain 800 ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(function(e,c) return c:IsType(TYPE_NORMAL) end)
		e1:SetValue(800)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
		aux.RegisterClientHint(c,0,tp,1,0,aux.Stringid(id,1))
		breakeff=true
	end
	if ct>=2 and Duel.IsExistingMatchingCard(s.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) then
		--● 2+: Negate the effects of 1 Effect Monster on the field, until the end of this turn
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
		local sc=Duel.SelectMatchingCard(tp,s.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
		if sc then
			Duel.HintSelection(sc)
			if breakeff then Duel.BreakEffect() end
			--Negate its effects until the end of this turn
			sc:NegateEffects(c,RESET_PHASE|PHASE_END)
			Duel.AdjustInstantly(sc)
		end
		breakeff=true
	end
	if ct>=3 then
		--● 3+: This turn, Normal Monsters you control cannot be destroyed by card effects
		if breakeff then Duel.BreakEffect() end
		--Normal Monsters you control cannot be destroyed by card effects this turn
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetTargetRange(LOCATION_MZONE,0)
		e2:SetTarget(function(e,c) return c:IsType(TYPE_NORMAL) end)
		e2:SetValue(1)
		e2:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e2,tp)
		aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,2))
		breakeff=true
	end
	if ct>=4 and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) then
		--● 4+: Shuffle 1 Effect Monster on the field into the Deck
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			if breakeff then Duel.BreakEffect() end
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
		breakeff=true
	end
	if ct>=5 and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) then
		--● 5+: Add 1 "The Toil of the Normal" from your Deck to your hand
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			if breakeff then Duel.BreakEffect() end
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end