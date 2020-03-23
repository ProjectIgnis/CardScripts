--Prescience
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(ep,id)>0 then return end
	--condition
	return aux.CanActivateSkill(tp) and Duel.GetLP(tp)<=(Duel.GetLP(1-tp)/2)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.RegisterFlagEffect(tp,id,0,0,1)
	--opd register
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	--first check because EVENT_ADJUST is not raised at the resolution of the skill
	local g=Duel.GetDecktopGroup(tp,1)
	local g2=Duel.GetDecktopGroup(1-tp,1)
	if #g>0 and g:GetFirst():GetFlagEffect(id)==0 then
		Duel.ConfirmDecktop(tp,1)
		g:GetFirst():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
	end
	if #g2>0 and g2:GetFirst():GetFlagEffect(id)==0 then
		Duel.ConfirmDecktop(1-e:GetHandler():GetControler(),1)
		g2:GetFirst():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
	end
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetOperation(s.operation)
	Duel.RegisterEffect(e2,tp)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDecktopGroup(e:GetHandler():GetControler(),1)
	local g2=Duel.GetDecktopGroup(1-e:GetHandler():GetControler(),1)
	
	if #g>0 and g:GetFirst():GetFlagEffect(id)==0 then
		Duel.ConfirmDecktop(tp,1)
		g:GetFirst():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
	end
	if #g2>0 and g2:GetFirst():GetFlagEffect(id)==0 then
		Duel.ConfirmDecktop(tp,1)
		g2:GetFirst():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end
