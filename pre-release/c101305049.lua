--三幻魔の霹靂
--Skyfire of the Sacred Beast
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--During your Main Phase: You can place 2 "Skyfire of the Sacred Beast" from your hand, Deck, and/or GY face-up on your field, then you can reveal 1 Level 10 "Sacred Beast" monster in your hand, then place 1 "Fallen Paradise of the Sacred Beasts" from your Deck face-up in your Field Zone
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.pltg)
	e1:SetOperation(s.plop)
	c:RegisterEffect(e1)
	--During your opponent's End Phase, if this card is in your GY: You can add it to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp) return Duel.IsTurnPlayer(1-tp) end)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_names={id,101305048} --"Fallen Paradise of the Sacred Beasts"
s.listed_series={SET_SACRED_BEAST}
function s.selfplfilter(c,tp)
	return c:IsCode(id) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>=2
		and Duel.IsExistingMatchingCard(s.selfplfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,2,nil,tp) end
end
function s.revealfilter(c)
	return c:IsLevel(10) and c:IsSetCard(SET_SACRED_BEAST) and not c:IsPublic()
end
function s.fieldplfilter(c,tp)
	return c:IsCode(101305048) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.selfplfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,2,2,nil,tp)
	if #g==2 then
		Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		Duel.MoveToField(g:GetNext(),tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		if Duel.IsExistingMatchingCard(s.revealfilter,tp,LOCATION_HAND,0,1,nil)
			and Duel.IsExistingMatchingCard(s.fieldplfilter,tp,LOCATION_DECK,0,1,nil,tp)
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
			local rg=Duel.SelectMatchingCard(tp,s.revealfilter,tp,LOCATION_HAND,0,1,1,nil)
			if #rg==0 then return end
			Duel.BreakEffect()
			Duel.ConfirmCards(1-tp,rg)
			Duel.ShuffleHand(tp)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
			local sc=Duel.SelectMatchingCard(tp,s.fieldplfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
			if sc then
				Duel.BreakEffect()
				Duel.MoveToField(sc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
			end
		end
	end
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end