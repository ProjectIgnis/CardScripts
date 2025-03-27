--福悲喜
--Fukubiki
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,LOCATION_DECK)>0 end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if (Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 or Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)==0) then return end
	if Duel.ShuffleDeck(tp)~=0 and Duel.ShuffleDeck(1-tp)~=0 then
		Duel.ConfirmDecktop(tp,1)
		Duel.ConfirmDecktop(1-tp,1)
		local tc1=Duel.GetDecktopGroup(tp,1):GetFirst()
		local tc2=Duel.GetDecktopGroup(1-tp,1):GetFirst()
		local atk1=tc1:GetTextAttack()
		local atk2=tc2:GetTextAttack()
		if atk1<0 then atk1=0 end
		if atk2<0 then atk2=0 end
		if atk1>atk2 and tc1:IsAbleToHand() and tc2:IsAbleToGrave() then
			Duel.DisableShuffleCheck()
			Duel.SendtoHand(tc1,tp,REASON_EFFECT)
			Duel.SendtoGrave(tc2,REASON_EFFECT)
		elseif atk1<atk2 and tc2:IsAbleToHand() and tc1:IsAbleToGrave() then
			Duel.DisableShuffleCheck()
			Duel.SendtoHand(tc2,1-tp,REASON_EFFECT)
			Duel.SendtoGrave(tc1,REASON_EFFECT)
		else
			Duel.DisableShuffleCheck()
			Duel.MoveSequence(tc1,1)
			Duel.MoveSequence(tc2,1)
		end
	end
end