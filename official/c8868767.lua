--ダイスエット
--Dice It
--scripted by andre
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DICE+CATEGORY_REMOVE+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.roll_dice=true
function s.rmfilter(c)
	return c:IsAbleToRemove() and aux.SpElimFilter(c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local turn_p=Duel.GetTurnPlayer()
	if chk==0 then
		local res=false
		if turn_p==tp then
			res=Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_GRAVE|LOCATION_MZONE,0,1,nil)
		else
			res=Duel.IsPlayerCanDiscardDeck(tp,1)
		end
		return res
	end
	e:SetLabel(turn_p)
	if turn_p==tp then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
		Duel.SetPossibleOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
	else
		Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
		Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local res=Duel.TossDice(tp,1)
	if e:GetLabel()==tp then
		--Activated during your turn
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local rg=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_GRAVE|LOCATION_MZONE,0,res,res,nil)
		if #rg==0 then return end
		if Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)==res and res==1 then
			Duel.BreakEffect()
			Duel.DiscardDeck(tp,6,REASON_EFFECT)
		end
	else
		--Activated during your opponent's turn
		if Duel.DiscardDeck(tp,res,REASON_EFFECT)==res and res==6 then
			local og=Duel.GetOperatedGroup()
			if og:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)~=res then return end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local rg=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_GRAVE|LOCATION_MZONE,0,1,1,nil)
			if #rg==0 then return end
			Duel.BreakEffect()
			Duel.Remove(rg,POS_FACEUP,REASON_EFFECT) 
		end
	end
end