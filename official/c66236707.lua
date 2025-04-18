--械刀婪魔皇断
--Gordian Schneider
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Banish cards from your hand and/or from your Extra Deck face-down and return the targeted cards to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() and not Duel.CheckPhaseActivity()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() and chkc:IsFaceup() and chkc~=c end
	local ct1=Duel.GetMatchingGroupCount(Card.IsAbleToRemove,tp,LOCATION_HAND,0,c,tp,POS_FACEDOWN)
	local ct2=Duel.GetMatchingGroupCount(Card.IsAbleToRemove,tp,LOCATION_EXTRA,0,nil,tp,POS_FACEDOWN)
	if chk==0 then return (ct1>=1 or ct2>=6) and Duel.IsExistingTarget(aux.FaceupFilter(Card.IsAbleToHand),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	local ct=ct1+(ct2//6)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsAbleToHand),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,c)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND|LOCATION_EXTRA)
end
function s.rescon(ct)
	return function(sg,e,tp,mg)
		local count=sg:FilterCount(Card.IsLocation,nil,LOCATION_HAND)
		local remaining=ct-count
		if remaining<0 then return false,true end
		local extracnt=sg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)
		local extra_needed=remaining*6
		if extracnt>extra_needed then return false,true end
		return extracnt==extra_needed,extracnt>extra_needed
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	local ct=#tg
	if ct==0 then return end
	local g1=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_HAND,0,nil,tp,POS_FACEDOWN)
	local g2=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_EXTRA,0,nil,tp,POS_FACEDOWN)
	if (#g1+#g2//6)<ct then return end
	local rg=g1+g2
	local sg=aux.SelectUnselectGroup(rg,e,tp,1,#rg,s.rescon(ct),1,tp,HINTMSG_REMOVE,s.rescon(ct),s.rescon(ct))
	if Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end