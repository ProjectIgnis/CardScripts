--Command Duel 3
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetDecktopGroup(tp,1)
	local g2=Duel.GetDecktopGroup(1-tp,1)
	if #g1<=0 or #g2<=0 then return end
	Duel.ConfirmDecktop(tp,1)
	Duel.ConfirmDecktop(1-tp,1)
	local tc=g1:GetFirst()
	if tc:IsMonster() and tc:IsAbleToHand() then
		Duel.DisableShuffleCheck()
		Duel.SendtoHand(g1,nil,REASON_EFFECT)
		Duel.ShuffleHand(tp)
	end
	tc=g2:GetFirst()
	if tc:IsMonster() and tc:IsAbleToHand() then
		Duel.DisableShuffleCheck()
		Duel.SendtoHand(g2,nil,REASON_EFFECT)
		Duel.ShuffleHand(1-tp)
	end
end