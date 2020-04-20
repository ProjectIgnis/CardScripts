--ダークネス ３
--Darkness 3
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
end
s.listed_names={511310104,511310105}
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:GetFlagEffect(511310104)~=0 then
		if Duel.GetCurrentChain()==1 then
			if Duel.Damage(tp,1000,REASON_EFFECT)==1000 then
				local ct=0
				if Duel.GetFlagEffect(tp,511310101)~=0 then ct=ct+1 end
				if Duel.GetFlagEffect(tp,511310102)~=0 then ct=ct+1 end
				if ct>0 then
					Duel.BreakEffect()
					Duel.Damage(tp,1000*ct,REASON_EFFECT)
				end
			end
		else
			Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,0)
		end
	end
end
