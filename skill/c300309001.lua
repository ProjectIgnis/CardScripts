--Sky God Revelation
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,2,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.flipop)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_SLIFER}
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	--Each player can draw until they have 6 cards if a Level 10 monster with ? ATK is Normal Summoned
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(0x5f)
	e1:SetCondition(s.drawcon)
	e1:SetOperation(s.drawop)
	Duel.RegisterEffect(e1,tp)
	--Activate 1 of these Skills once per turn
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCountLimit(1)
	e2:SetRange(0x5f)
	e2:SetCondition(s.effcon)
	e2:SetOperation(s.effop)
	Duel.RegisterEffect(e2,tp)
end
--Draw functions
function s.lv10filter(c,tp)
	return c:IsMonster() and c:GetTextAttack()==-2 and c:IsLevel(10) and c:IsControler(tp)
end
function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.lv10filter,1,nil,tp)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	local h1=6-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	local h2=6-Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)
	--You draw
	if h1>0 and Duel.IsPlayerCanDraw(tp,h1) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Draw(tp,h1,REASON_EFFECT)
	end
	--Your opponent draws
	if h2>0 and Duel.IsPlayerCanDraw(1-tp,h2) and Duel.SelectYesNo(1-tp,aux.Stringid(id,0)) then
		Duel.Draw(1-tp,h2,REASON_EFFECT)
	end
end
--Skill choice functions
function s.tdfilter(c)
	return c:IsCode(CARD_SLIFER) and c:IsAbleToDeck() and not c:IsPublic()
end
function s.thfilter(c)
	return c:IsCode(CARD_SLIFER) and c:IsAbleToHand()
end
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_HAND,0,1,nil) and Duel.IsPlayerCanDraw(tp,1)
	local b2=Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) 
		and not Duel.HasFlagEffect(tp,id+100)
	return aux.CanActivateSkill(tp) and (b1 or b2) and not Duel.HasFlagEffect(tp,id)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_HAND,0,1,nil) and Duel.IsPlayerCanDraw(tp)
	local b2=Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) 
		and not Duel.HasFlagEffect(tp,id+100)
	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,1)},{b2,aux.Stringid(id,2)})
	if op==1 then
		Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
		Duel.Hint(HINT_CARD,tp,id)
		--You can only use 1 Skill per turn
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		--Place 1 "Slifer The Sky Dragon" on the bottom of the Deck to draw 1 card
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local tc=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
		Duel.ConfirmCards(1-tp,tc)
		Duel.ShuffleHand(tp)
		if tc and Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_DECK) and Duel.IsPlayerCanDraw(tp,1) then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	elseif op==2 then
		Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
		Duel.Hint(HINT_CARD,tp,id)
		--You can only use 1 Skill per turn
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		--You can only use this Skill once per Duel
		Duel.RegisterFlagEffect(tp,id+100,0,0,0)
		--Discard 1 card to add "Slifer The Sky Dragon" from your Deck to your hand
		if Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST|REASON_DISCARD,nil)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
			if sc then
				Duel.BreakEffect()
				Duel.SendtoHand(sc,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,sc)
				Duel.ShuffleHand(tp)
			end
		end
	end
end