--竜の影光
--Dragon's Light and Darkness
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
function s.tdfilter(c,tp)
	return c:IsLevel(8) and c:IsRace(RACE_DRAGON) and c:IsAbleToDeck()
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetAttribute())
end
function s.thfilter(c,attr)
	return c:IsLevel(8) and c:IsRace(RACE_DRAGON) and not c:IsAttribute(attr) and c:IsAbleToHand()
end
function s.atkfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsFaceup() and c:HasLevel()
end
function s.disfilter(c,tp)
	return c:IsRace(RACE_DRAGON) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return e:GetLabel()==2 and chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.atkfilter(chkc) end
	local dmg_step=Duel.IsPhase(PHASE_DAMAGE)
	local ex,_,_,te_ev,te_re=Duel.CheckEvent(EVENT_CHAINING,true)
	local te_tg=te_ev and Duel.GetChainInfo(te_ev,CHAININFO_TARGET_CARDS) or nil
	--Shuffle 1 Level 8 Dragon monster from your hand into the Deck, and if you do, add 1 Level 8 Dragon monster with a different Attribute from your Deck to your hand
	local b1=not Duel.HasFlagEffect(tp,id) and not dmg_step
		and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_HAND,0,1,nil,tp)
	--Make 1 Dragon monster you control gain ATK equal to its Level x 200
	local b2=not Duel.HasFlagEffect(tp,id+1) and not (dmg_step and Duel.IsDamageCalculated())
		and Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,nil)
	--Negate an effect that targets a Dragon monster(s) you control
	local b3=not Duel.HasFlagEffect(tp,id+2) and not dmg_step
		and ex and te_re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and te_tg
		and te_tg:IsExists(s.disfilter,1,nil,tp) and Duel.IsChainDisablable(ev)
	if chk==0 then return b1 or b2 or b3 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b3,aux.Stringid(id,3)})
	e:SetLabel(op,te_ev or 0)
	if op==1 then
		e:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND+CATEGORY_SEARCH)
		e:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		e:SetCategory(CATEGORY_ATKCHANGE)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
		Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
		Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
	elseif op==3 then
		e:SetCategory(CATEGORY_DISABLE)
		e:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
		Duel.RegisterFlagEffect(tp,id+2,RESET_PHASE|PHASE_END,0,1)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,tp,0)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op,te_ev=e:GetLabel()
	if op==1 then
		--Shuffle 1 Level 8 Dragon monster from your hand into the Deck, and if you do, add 1 Level 8 Dragon monster with a different Attribute from your Deck to your hand
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sc=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
		if not sc then return end
		Duel.ConfirmCards(1-tp,sc)
		if Duel.SendtoDeck(sc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 or not sc:IsLocation(LOCATION_DECK) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,sc:GetAttribute())
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	elseif op==2 then
		--Make 1 Dragon monster you control gain ATK equal to its Level x 200
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:HasLevel() then
			--Gains ATK equal to its Level x 200
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(tc:GetLevel()*200)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	elseif op==3 then
		--Negate an effect that targets a Dragon monster(s) you control
		Duel.NegateEffect(te_ev)
	end
end