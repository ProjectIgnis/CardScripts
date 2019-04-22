--performapal signal
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.tg(e,tp,eg,ev,ep,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
end
function s.op(e,tp,eg,ev,ep,re,r,rp)
	if not Duel.IsPlayerCanDraw(tp,1) then return end
	if Duel.Draw(tp,1,REASON_EFFECT)~=0 then
		local c=Duel.GetOperatedGroup():GetFirst()
		Duel.ConfirmCards(1-tp,c)
		Duel.SendtoGrave(c,REASON_EFFECT)
		if c:IsType(TYPE_MONSTER) and c:IsSetCard(0x9f) then
			Duel.NegateAttack()
		end
	end
end