--ペア・ルック
--Matching Outfits
--
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g1=Duel.GetDecktopGroup(tp,1)
		local tc1=g1:GetFirst()
		local g2=Duel.GetDecktopGroup(1-tp,1)
		local tc2=g2:GetFirst()
		return tc1 and tc2 and tc1:IsAbleToRemove(tp) and tc2:IsAbleToRemove(1-tp) and tc1:IsAbleToHand() and tc2:IsAbleToHand()
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 or Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)==0 then return end
	Duel.ConfirmDecktop(tp,1)
	Duel.ConfirmDecktop(1-tp,1)
	local g1=Duel.GetDecktopGroup(tp,1)
	local tc1=g1:GetFirst()
	local g2=Duel.GetDecktopGroup(1-tp,1)
	local tc2=g2:GetFirst()
	if (tc1:GetMainCardType()==tc2:GetMainCardType()) then
		Duel.DisableShuffleCheck()
		Duel.SendtoHand(tc1,nil,REASON_EFFECT)
		Duel.SendtoHand(tc2,nil,REASON_EFFECT)
		Duel.ShuffleHand(tp)
		Duel.ShuffleHand(1-tp)
	else
		Duel.DisableShuffleCheck()
		Duel.Remove(tc1,POS_FACEUP,REASON_EFFECT)
		Duel.Remove(tc2,POS_FACEUP,REASON_EFFECT)
	end
end