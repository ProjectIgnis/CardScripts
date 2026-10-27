--道化の一座 ドリッシュ
--Clown Crew Dristy
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 2 Ritual, Fusion, Synchro, Xyz, and/or Pendulum Monsters
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_RITUAL|TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_PENDULUM),2)
	--Your Tribute Summoned monsters can make a second attack during each Battle Phase
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsTributeSummoned))
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--If this card is Tributed: You can activate 1 of these effects (but you can only use each effect of "Clown Crew Dristy" once per turn);
	--● Return all Link Monsters from the field and the GYs to the Extra Deck
	--● Each player with a hand shuffles their entire hand into the Deck, then draws the same number of cards they shuffled into the Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_RELEASE)
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	--● Return all Link Monsters from the field and the GYs to the Extra Deck
	local option_1=not Duel.HasFlagEffect(tp,id)
		and Duel.IsExistingMatchingCard(aux.AND(Card.IsLinkMonster,Card.IsFaceup,Card.IsAbleToExtra),tp,LOCATION_MZONE|LOCATION_GRAVE,LOCATION_MZONE|LOCATION_GRAVE,1,nil)
	--● Each player with a hand shuffles their entire hand into the Deck, then draws the same number of cards they shuffled into the Deck
	local option_2=not Duel.HasFlagEffect(tp,id+1) and ((Duel.IsPlayerCanDraw(tp)
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,nil))
		or (Duel.IsPlayerCanDraw(1-tp) and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_HAND,1,nil)))
	if chk==0 then return option_1 or option_2 end
	local choice=Duel.SelectEffect(tp,
		{option_1,aux.Stringid(id,1)},
		{option_2,aux.Stringid(id,2)})
	e:GetChainData().choice=choice
	if choice==1 then
		--● Return all Link Monsters from the field and the GYs to the Extra Deck
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		e:SetCategory(CATEGORY_TOEXTRA)
		Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,PLAYER_ALL,LOCATION_MZONE|LOCATION_GRAVE)
	elseif choice==2 then
		--● Each player with a hand shuffles their entire hand into the Deck, then draws the same number of cards they shuffled into the Deck
		Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
		e:SetCategory(CATEGORY_TODECK|CATEGORY_DRAW)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,PLAYER_ALL,LOCATION_HAND)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local choice=e:GetChainData().choice
	if choice==1 then
		--● Return all Link Monsters from the field and the GYs to the Extra Deck
		local g=Duel.GetMatchingGroup(aux.AND(Card.IsLinkMonster,Card.IsFaceup,Card.IsAbleToExtra),tp,LOCATION_MZONE|LOCATION_GRAVE,LOCATION_MZONE|LOCATION_GRAVE,nil)
		if #g>0 then
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	elseif choice==2 then
		--● Each player with a hand shuffles their entire hand into the Deck, then draws the same number of cards they shuffled into the Deck
		local g=Duel.GetFieldGroup(tp,LOCATION_HAND,LOCATION_HAND)
		if Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)>0 then
			local og=Duel.GetOperatedGroup():Match(Card.IsLocation,nil,LOCATION_DECK)
			local turn_player=Duel.GetTurnPlayer()
			local non_turn_player=1-turn_player
			if og:IsExists(Card.IsControler,1,nil,turn_player) then Duel.ShuffleDeck(turn_player) end
			if og:IsExists(Card.IsControler,1,nil,non_turn_player) then Duel.ShuffleDeck(non_turn_player) end
			local turn_player_drawcount=og:FilterCount(Card.IsPreviousControler,nil,turn_player)
			local non_turn_player_drawcount=og:FilterCount(Card.IsPreviousControler,nil,non_turn_player)
			local break_chk=true
			if turn_player_drawcount>0 then
				break_chk=false
				Duel.BreakEffect()
				Duel.Draw(turn_player,turn_player_drawcount,REASON_EFFECT)
			end
			if non_turn_player_drawcount>0 then
				if break_chk then Duel.BreakEffect() end
				Duel.Draw(non_turn_player,non_turn_player_drawcount,REASON_EFFECT)
			end
		end
	end
end