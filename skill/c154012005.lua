--Trap Search
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--skill
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
s.listed_names={77585513}
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	local fg=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_TRAP)
	return aux.CanActivateSkill(tp) and #fg>0 and Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsOriginalCode,77585513),tp,LOCATION_MZONE,0,1,nil) and Duel.GetFlagEffect(ep,id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--opd register
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	--Trap Search
	local fg=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_TRAP)
	if #fg>0 then
		Duel.Destroy(fg,REASON_EFFECT)
	end
end

