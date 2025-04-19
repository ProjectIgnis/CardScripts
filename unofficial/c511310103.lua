--ダークネス ３
--Darkness 3
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
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
end
s.listed_names={511310104,511310105}
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if Duel.GetCurrentChain()==1 then
		Duel.SetTargetPlayer(1-tp)
		Duel.SetTargetParam(1000)
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
	end
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.GetCurrentChain()==1 then
		if Duel.Damage(1-tp,1000,REASON_EFFECT)==1000 then
			local ct=0
			if Duel.GetFlagEffect(tp,511310101)~=0 then ct=ct+1 end
			if Duel.GetFlagEffect(tp,511310102)~=0 then ct=ct+1 end
			if ct>0 then
				Duel.BreakEffect()
				Duel.Damage(1-tp,1000*ct,REASON_EFFECT)
			end
		end
	else
		Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,0)
	end
end