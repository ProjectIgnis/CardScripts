--等価交換
--Fair Exchange
local s,id=GetID()
function s.initial_effect(c)
	--discard deck
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,3) and Duel.IsPlayerCanDiscardDeck(1-tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(3)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,3,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)>0 then
		local og=Duel.GetOperatedGroup()
		if og:FilterCount(Card.IsAbleToGrave,nil)==#og and Duel.SendtoGrave(og,REASON_EFFECT)==#og then
			local g=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_GRAVE)
			local sum=g:GetSum(Card.GetLevel)
			local dg=Duel.GetDecktopGroup(1-tp,sum)
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end