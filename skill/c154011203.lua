--Sleight of Hand
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--skill
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
	aux.GlobalCheck(s,function()
		s[0]=nil
		s[1]=nil
		s[2]=0
		s[3]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_names={86198326}
function s.checkop()
	for tp=0,1 do
		if not s[tp] then s[tp]=Duel.GetLP(tp) end
		if s[tp]>Duel.GetLP(tp) then
			s[2+tp]=s[2+tp]+(s[tp]-Duel.GetLP(tp))
			s[tp]=Duel.GetLP(tp)
		end
	end
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--tpd check
	if Duel.GetFlagEffect(ep,id)>1 then return end
	--condition
	return Duel.GetCurrentChain()==0 and tp==Duel.GetTurnPlayer() and s[2+tp]>=1500 and aux.CanActivateSkill(tp) 
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--counter
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	--Wristband access
	local tc=Duel.CreateToken(tp,86198326)
	if Duel.SendtoHand(tc,tp,REASON_EFFECT)>0 then
		Duel.Hint(HINT_SKILL_FLIP,tp,id|(2<<32))
		s[2+tp]=0
	end
end

