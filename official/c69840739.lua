--アーティファクト－デュランダル
--Artifact Durendal
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 5 monsters
	Xyz.AddProcedure(c,nil,5,2)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1)
	e1:SetCost(Cost.Detach(1))
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local event_chaining,_,_,event_value,reason_effect,_,reason_player=Duel.CheckEvent(EVENT_CHAINING,true)
	--The activated effect becomes "Destroy 1 Spell/Trap Card your opponent controls"
	local b1=event_chaining and Duel.IsExistingMatchingCard(Card.IsSpellTrap,reason_player,0,LOCATION_ONFIELD,1,nil)
		and ((reason_effect:IsMonsterEffect() and Duel.GetChainInfo(event_value,CHAININFO_TRIGGERING_LOCATION)==LOCATION_MZONE)
		or (reason_effect:GetHandler():IsNormalSpellTrap() and reason_effect:IsHasType(EFFECT_TYPE_ACTIVATE)))
	--Each player with a hand shuffles their entire hand into the Deck, then draws the same number of cards they shuffled into the Deck
	local b2=(Duel.IsPlayerCanDraw(tp) or Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0)
		and (Duel.IsPlayerCanDraw(1-tp) or Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)==0)
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,LOCATION_HAND,1,nil)
	if chk==0 then return b1 or b2 end
	local op=not b1 and 2
		or Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,1)},
			{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(0)
		Duel.SetTargetParam(event_value)
	elseif op==2 then
		e:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
		if not b1 then Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2)) end
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,PLAYER_ALL,LOCATION_HAND)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--The activated effect becomes "Destroy 1 Spell/Trap Card your opponent controls"
		local g=Group.CreateGroup()
		local event_value=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
		Duel.ChangeTargetCard(event_value,g)
		Duel.ChangeChainOperation(event_value,s.repop)
	elseif op==2 then
		--Each player with a hand shuffles their entire hand into the Deck, then draws the same number of cards they shuffled into the Deck
		local g=Duel.GetFieldGroup(tp,LOCATION_HAND,LOCATION_HAND)
		if Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)>0 then
			local og=Duel.GetOperatedGroup():Match(Card.IsLocation,nil,LOCATION_DECK)
			local turn_player=Duel.GetTurnPlayer()
			local non_turn_player=1-turn_player
			if og:IsExists(Card.IsControler,1,nil,turn_player) then Duel.ShuffleDeck(turn_player) end
			if og:IsExists(Card.IsControler,1,nil,non_turn_player) then Duel.ShuffleDeck(non_turn_player) end
			local ct1=og:FilterCount(Card.IsPreviousControler,nil,turn_player)
			local ct2=og:FilterCount(Card.IsPreviousControler,nil,non_turn_player)
			Duel.BreakEffect()
			if ct1>0 then
				Duel.Draw(turn_player,ct1,REASON_EFFECT)
			end
			if ct2>0 then
				Duel.Draw(non_turn_player,ct2,REASON_EFFECT)
			end
		end
	end
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsNormalSpellTrap() then
		c:CancelToGrave(false)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end
