--Executive Privilege
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
s.listed_names={CARD_OBELISK,CARD_BLUEEYES_W_DRAGON}
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	--"Obelisk the Tormentor" can attack all monsters your opponent controls, once each
	local e1a=Effect.CreateEffect(e:GetHandler())
	e1a:SetType(EFFECT_TYPE_SINGLE)
	e1a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1a:SetCode(EFFECT_ATTACK_ALL)
	e1a:SetRange(LOCATION_MZONE)
	e1a:SetValue(1)
	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e1b:SetRange(0x5f)
	e1b:SetTargetRange(LOCATION_MZONE,0)
	e1b:SetTarget(function(e,c) return c:IsCode(CARD_OBELISK) end)
	e1b:SetLabelObject(e1a)
	Duel.RegisterEffect(e1b,tp)
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
--Skill choice functions
function s.obtdfilter(c,tp)
	return c:IsCode(CARD_OBELISK) and c:IsAbleToDeckAsCost() and not c:IsPublic() and Duel.IsExistingMatchingCard(s.betdfilter,tp,LOCATION_HAND,0,1,nil)
end
function s.betdfilter(c)
	return c:IsCode(CARD_BLUEEYES_W_DRAGON) and c:IsAbleToDeckAsCost() and not c:IsPublic()
end
function s.thfilter(c)
	return c:IsCode(CARD_OBELISK) and c:IsAbleToHand()
end
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.IsExistingMatchingCard(s.obtdfilter,tp,LOCATION_HAND,0,1,nil,tp) and Duel.IsPlayerCanDraw(tp,2)
	local b2=Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) 
		and not Duel.HasFlagEffect(tp,id+100)
	return aux.CanActivateSkill(tp) and (b1 or b2) and not Duel.HasFlagEffect(tp,id)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.IsExistingMatchingCard(s.obtdfilter,tp,LOCATION_HAND,0,1,nil,tp) and Duel.IsPlayerCanDraw(tp,2)
	local b2=Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) 
		and not Duel.HasFlagEffect(tp,id+100)
	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)})
	if op==1 then
		Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
		Duel.Hint(HINT_CARD,tp,id)
		--You can only use 1 Skill per turn
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		--Place 1 "Obelisk the Tormentor" and 1 "Blue-Eyes White Dragon" on the bottom of the Deck to draw 2 card
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local obg=Duel.SelectMatchingCard(tp,s.obtdfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local beg=Duel.SelectMatchingCard(tp,s.betdfilter,tp,LOCATION_HAND,0,1,1,nil)
		obg:Merge(beg)
		Duel.ConfirmCards(1-tp,obg)
		Duel.ShuffleHand(tp)
		if obg and Duel.SendtoDeck(obg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 and obg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)==2 and Duel.IsPlayerCanDraw(tp,2) then
			Duel.SortDeckbottom(tp,tp,2)
			Duel.BreakEffect()
			Duel.Draw(tp,2,REASON_EFFECT)
		end
	elseif op==2 then
		Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
		Duel.Hint(HINT_CARD,tp,id)
		--You can only use 1 Skill per turn
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		--You can only use this Skill once per Duel
		Duel.RegisterFlagEffect(tp,id+100,0,0,0)
		--Discard 1 card to add "Obelisk the Tormentor" from your Deck to your hand
		if Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST|REASON_DISCARD,nil)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
			if sc then
				Duel.BreakEffect()
				Duel.SendtoHand(sc,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,sc)
				Duel.ShuffleHand(tp)
				Duel.ShuffleDeck(tp)
			end
		end
	end
end