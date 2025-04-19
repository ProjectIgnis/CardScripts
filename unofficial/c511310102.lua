--ダークネス ２
--Darkness 2
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Apply
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_CUSTOM+511310104)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
s.listed_names={511310104,511310105}
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.GetCurrentChain()==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACK)
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
		local ac=g:Select(tp,1,1,nil):GetFirst()
		if ac and ac:UpdateAttack(1000,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,c)==1000 then
			local ct=0
			if Duel.GetFlagEffect(tp,511310101)~=0 then ct=ct+1 end
			if Duel.GetFlagEffect(tp,511310103)~=0 then ct=ct+1 end
			if ct>0 then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACK)
				local ac2=g:Select(tp,ct,ct,nil):GetFirst()
				ac2:UpdateAttack(ct*1000,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,c)
			end
		end
	else
		Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,0)
	end
end