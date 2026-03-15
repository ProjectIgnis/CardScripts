--雷盟－ブレイクアウェイ
--Blitzclique - Breakaway
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects;
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(s.effcost)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--If a card(s) is destroyed by your "Blitzclique" card's effect, while this card is in your GY: You can add this card to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.selfthcon)
	e2:SetTarget(s.selfthtg)
	e2:SetOperation(s.selfthop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_BLITZCLIQUE}
function s.plfilter(c,tp)
	return c:IsSetCard(SET_BLITZCLIQUE) and c:IsContinuousTrap() and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.descostfilter(c,hc)
	return c:IsRace(RACE_THUNDER) and c:IsFaceup() and c:IsAbleToHandAsCost()
		and Duel.IsExistingTarget(nil,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c:GetEquipGroup()+c+hc)
end
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if c:IsLocation(LOCATION_HAND) then ft=ft-1 end
	--● Place 1 "Blitzclique" Continuous Trap from your Deck face-up on your field
	local b1=ft>0 and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_DECK,0,1,nil,tp)
	--● Return 1 Thunder monster you control to the hand, then target 1 card on the field; destroy it
	local b2=Duel.IsExistingMatchingCard(s.descostfilter,tp,LOCATION_MZONE,0,1,nil,c)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local g=Duel.SelectMatchingCard(tp,s.descostfilter,tp,LOCATION_MZONE,0,1,1,nil,c)
		Duel.HintSelection(g)
		Duel.SendtoHand(g,nil,REASON_COST)
	end
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)==2 and chkc:IsOnField() and chkc~=c end
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if c:IsLocation(LOCATION_HAND) then ft=ft-1 end
	--● Place 1 "Blitzclique" Continuous Trap from your Deck face-up on your field
	local b1=ft>0 and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_DECK,0,1,nil,tp)
	--● Return 1 Thunder monster you control to the hand, then target 1 card on the field; destroy it
	local b2=Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
	if chk==0 then return b1 or b2 end
	local op=nil
	local label=e:GetLabel()
	if label~=0 then
		op=label
	else
		op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,2)},
			{b2,aux.Stringid(id,3)})
	end
	e:SetLabel(0)
	Duel.SetTargetParam(op)
	if op==1 then
		e:SetCategory(0)
		e:SetProperty(0)
	elseif op==2 then
		e:SetCategory(CATEGORY_DESTROY)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if op==1 then
		--● Place 1 "Blitzclique" Continuous Trap from your Deck face-up on your field
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local sc=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
		if sc then
			Duel.MoveToField(sc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		end
	elseif op==2 then
		--● Return 1 Thunder monster you control to the hand, then target 1 card on the field; destroy it
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
function s.selfthcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re and not eg:IsContains(e:GetHandler()) and eg:IsExists(Card.IsReason,1,nil,REASON_EFFECT)
		and re:GetHandler() and re:GetHandler():IsSetCard(SET_BLITZCLIQUE)
end
function s.selfthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
end
function s.selfthop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end