--Bandit
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--opd check
	if Duel.GetFlagEffect(ep,id)>0 then return end
	--condition
	return aux.CanActivateSkill(tp)
		and Duel.GetLP(tp)<=1500
		and Duel.GetMatchingGroupCount(s.filter,tp,0,LOCATION_ONFIELD,nil)>0
end
function s.filter(c)
	return c:IsFacedown() and c:IsAbleToChangeControler()
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--opd register
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	g=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_SZONE,1,1,nil)
	Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEDOWN,true)
end
