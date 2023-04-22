--Cold-Blooded Tactician
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
end
function s.repfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsFaceup() and c:IsMonster()
end
function s.posfilter(c)
	return c:IsCanChangePosition() and c:IsMonster()
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	local pg=Duel.GetMatchingGroup(s.repfilter,tp,LOCATION_MZONE,0,nil)
	local og=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
	return aux.CanActivateSkill(tp) and #pg>0 and #og>0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local pg=Duel.GetMatchingGroup(s.repfilter,tp,LOCATION_MZONE,0,nil)
	local og=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
	if #pg==0 and #og==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local posg=og:FilterSelect(tp,s.posfilter,1,#pg,nil)
	Duel.ChangePosition(posg,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
end




 