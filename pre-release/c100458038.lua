--虚蝕異解△ジャハンナム
--Emptiness Devouring Xenovader△ Jahannam
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--If this card is Normal or Special Summoned: Banish (face-down) the top 8 cards of your Deck
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_REMOVE)
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1a:SetCode(EVENT_SUMMON_SUCCESS)
	e1a:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return true end
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,8,tp,LOCATION_DECK)
	end)
	e1a:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local g=Duel.GetDecktopGroup(tp,8)
		if #g>0 then
			Duel.DisableShuffleCheck()
			Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
		end
	end)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	--Gains these effects based on the total number of face-down banished cards
	--● 10+: Cannot be destroyed by battle
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetCondition(s.condition(10))
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--● 20+: Once per turn (Quick Effect): You can target 1 card on the field; destroy it
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.condition(20))
	e3:SetCost(Cost.HintSelectedEffect)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	e3:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e3)
	--● 30+: Once per turn, during your opponent's End Phase: You can add 1 of your face-down banished cards to your hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.thcon)
	e4:SetCost(Cost.HintSelectedEffect)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
	--● 40+: Skip both players' Draw Phases
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EFFECT_SKIP_DP)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.condition(40))
	e5:SetTargetRange(1,1)
	c:RegisterEffect(e5)
end
function s.condition(ct)
	return function(e)
		return Duel.GetMatchingGroupCount(Card.IsFacedown,0,LOCATION_REMOVED,LOCATION_REMOVED,nil)>=ct
	end
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return s.condition(30)(e) and Duel.IsTurnPlayer(1-tp)
end
function s.thfilter(c)
	return c:IsFacedown() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end