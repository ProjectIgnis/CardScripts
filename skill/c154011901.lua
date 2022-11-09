--Posthumous Army
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
function s.flipcon(e)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetFieldGroup(0,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE):Filter(Card.IsType,nil,TYPE_MONSTER)
	return aux.CanActivateSkill(tp) and tp==Duel.GetTurnPlayer() and s[2+tp]>=1000 and #g>0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	--race change
	local g=Duel.GetFieldGroup(0,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE):Filter(Card.IsType,nil,TYPE_MONSTER)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetRange(0x5f)
		e1:SetTargetRange(LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(RACE_ZOMBIE)
		e1:SetReset(RESET_TODECK+RESET_REMOVE+RESET_TOHAND+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
	end
	s[2+tp]=0
end
	
	