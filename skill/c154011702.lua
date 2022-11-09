--Guardian Call
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--skill
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
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
s.listed_series={0x52}
function s.checkop()
	for tp=0,1 do
		if not s[tp] then s[tp]=Duel.GetLP(tp) end
		if s[tp]>Duel.GetLP(tp) then
			s[2+tp]=s[2+tp]+(s[tp]-Duel.GetLP(tp))
			s[tp]=Duel.GetLP(tp)
		end
	end
end
function s.filter(c)
	return c:IsSetCard(0x52) and c:IsAbleToHand()
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return aux.CanActivateSkill(tp) and tp==Duel.GetTurnPlayer() and s[2+tp]>=1800 and Duel.GetFlagEffect(ep,id)==0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--opd register
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	--Add 1 Guardian card
	local g=Duel.GetMatchingGroup(tp,s.filter,LOCATION_DECK,0,nil)
	local tc=g:RandomSelect(tp,1):GetFirst()
	if Duel.SendtoHand(tc,tp,REASON_EFFECT)~=0 then
		s[2+tp]=0
	end
end
