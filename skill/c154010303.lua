--Roll n Boost
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
	return c:IsMonster() and not c:IsPublic()
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return aux.CanActivateSkill(tp) and s[2+tp]>=2000 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Roll n Boost
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	Duel.ConfirmCards(tp,tc)
	local td=Duel.TossDice(tp,1)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(td)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(2<<32))
	s[2+tp]=0
end


