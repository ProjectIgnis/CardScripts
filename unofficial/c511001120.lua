--予言
--Prophecy
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetHintTiming(0,TIMING_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_HAND,1,1,nil):GetFirst()
	if not tc then return end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	Duel.ConfirmCards(tp,tc)
	Duel.ShuffleHand(1-tp)
	local atk=tc:GetTextAttack()
	if not tc:IsMonster() or atk<0 then return end
	if (op==0 and atk>2000) or (op==1 and atk<2000) then
		Duel.SendtoHand(tc,tp,REASON_EFFECT)
	end
end