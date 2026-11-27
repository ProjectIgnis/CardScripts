--お返し鶴秘姫
--The Secret Crane Princess Who Returns A Favor
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--During your opponent's End Phase: You can place this card from your GY on top of the Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.IsTurnPlayer(1-tp)
	end)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	--During the Main Phase (Quick Effect): You can return this card from the field to the hand, and if you do, each player draws 1 card, then your opponent can draw 1 card, and if they do, you must keep your hand revealed during this Main Phase
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.IsMainPhase()
	end)
	e2:SetTarget(s.rthdrawtg)
	e2:SetOperation(s.rthdrawop)
	e2:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e2)
	--(Quick Effect): You can banish this revealed card from your hand; destroy all face-up cards your opponent controls
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():IsPublic()
	end)
	e3:SetCost(Cost.SelfBanish)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	e3:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e3)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,tp,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)>0 then
		Duel.ConfirmDecktop(tp,1)
	end
end
function s.rthdrawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() and Duel.IsPlayerCanDraw(tp,1)
		and Duel.IsPlayerCanDraw(1-tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
end
function s.rthdrawop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)>0 and c:IsLocation(LOCATION_HAND) then
		Duel.ShuffleHand(c:GetControler())
		local opp=1-tp
		local turn_player=Duel.GetTurnPlayer()
		if Duel.Draw(turn_player,1,REASON_EFFECT)>0 and Duel.Draw(1-turn_player,1,REASON_EFFECT)>0
			and Duel.IsPlayerCanDraw(opp,1) and Duel.SelectYesNo(opp,aux.Stringid(id,3)) then
			Duel.BreakEffect()
			if Duel.Draw(opp,1,REASON_EFFECT)==0 then return end
			local reset_phase=Duel.IsMainPhase1() and PHASE_MAIN1 or PHASE_MAIN2
			--Then your opponent can draw 1 card, and if they do, you must keep your hand revealed during this Main Phase
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_PUBLIC)
			e1:SetTargetRange(LOCATION_HAND,0)
			e1:SetReset(RESET_PHASE|reset_phase)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end