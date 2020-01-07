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
	rg1=rg1:Filter(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	local rg2=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	Duel.SendtoDeck(rg2,nil,2,REASON_EFFECT)
	rg2=rg2:Filter(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	Duel.BreakEffect()
	if #rg1>0 then
		Duel.ShuffleDeck(tp)
	end
	if #rg2>0 then
		Duel.ShuffleDeck(1-tp)
	end
	local sum1=0
	local sum2=0
	local tc1=rg1:GetFirst()
	while tc1 do
		local lv=tc1:GetLevel()
		sum1=sum1+lv
		tc1=rg1:GetNext()
	end
	local tc2=rg2:GetFirst()
	while tc2 do
		local lv=tc2:GetLevel()
		sum2=sum2+lv
		tc2=rg2:GetNext()
	end
	local d1=Duel.GetDecktopGroup(tp,sum1)
	local d2=Duel.GetDecktopGroup(1-tp,sum2)
	Duel.Draw(tp,sum1,REASON_EFFECT)
	Duel.Draw(1-tp,sum2,REASON_EFFECT)
	Duel.BreakEffect()
	Duel.ConfirmCards(1-tp,d1)
	Duel.ConfirmCards(tp,d2)
	tc1=rg1:GetFirst()
	tc2=rg2:GetFirst()
	local check1=false
	local check2=false
	while tc1 and check1==false do
		local tcd1=d1:GetFirst()
		while tcd1 and check1==false do
			if tc1==tcd1 then
				check1=true
			end
			tcd1=d1:GetNext()
		end
		tc1=rg1:GetNext()
	end
	while tc2 and check2==false do
		local tcd2=d2:GetFirst()
		while tcd2 and check2==false do
			if tc2==tcd2 then
				check2=true
			end
			tcd2=d2:GetNext()
		end
		tc2=rg2:GetNext()
	end
	Duel.BreakEffect()
	if check1==false then
		Duel.SendtoGrave(d1,REASON_EFFECT+REASON_DISCARD)
	end
	Duel.BreakEffect()
	if check2==false then
		Duel.SendtoGrave(d2,REASON_EFFECT+REASON_DISCARD)
	end
	Duel.BreakEffect()
	Duel.ShuffleHand(tp)
	Duel.ShuffleHand(1-tp)
end
