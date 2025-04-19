--Level Jar
local s,id=GetID()
function s.initial_effect(c)
	--flip
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return not c:IsStatus(STATUS_BATTLE_DESTROYED) and c:IsAbleToDeck()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local rg1=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	Duel.SendtoDeck(rg1,nil,2,REASON_EFFECT)
	rg1=Duel.GetOperatedGroup():Match(Card.IsLocation,nil,LOCATION_DECK|LOCATION_EXTRA)
	local rg2=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	Duel.SendtoDeck(rg2,nil,2,REASON_EFFECT)
	rg2=Duel.GetOperatedGroup():Match(Card.IsLocation,nil,LOCATION_DECK|LOCATION_EXTRA)
	Duel.BreakEffect()
	if #rg1>0 then
		Duel.ShuffleDeck(tp)
	end
	if #rg2>0 then
		Duel.ShuffleDeck(1-tp)
	end
	local sum1=rg1:GetSum(Card.GetLevel)
	local sum2=rg2:GetSum(Card.GetLevel)
	Duel.Draw(tp,sum1,REASON_EFFECT)
	local d1=Duel.GetOperatedGroup()
	Duel.Draw(1-tp,sum2,REASON_EFFECT)
	local d2=Duel.GetOperatedGroup()
	Duel.BreakEffect()
	Duel.ConfirmCards(1-tp,d1)
	Duel.ConfirmCards(tp,d2)
	tc1=rg1:GetFirst()
	tc2=rg2:GetFirst()
	local check1=#(d1&rg1)>0
	local check2=#(d2&rg2)>0
	Duel.BreakEffect()
	if not check1 then
		Duel.SendtoGrave(d1,REASON_EFFECT+REASON_DISCARD)
	end
	if not check2 then
		Duel.SendtoGrave(d2,REASON_EFFECT+REASON_DISCARD)
	end
	Duel.BreakEffect()
	Duel.ShuffleHand(tp)
	Duel.ShuffleHand(1-tp)
end