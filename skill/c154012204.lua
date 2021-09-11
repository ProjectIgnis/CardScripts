--Mask of Restrict (Skill)
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
end
s.listed_names={48948935,49064413,29549364}
function s.filter(c)
	return (c:IsCode(48948935) or c:IsCode(49064413))
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	if Duel.GetFlagEffect(ep,id)>1 then return end 
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(s.filter),tp,LOCATION_MZONE,0,1,1,nil) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--tpd register
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	--Mask of Restrict
	local tc=Duel.CreateToken(tp,29549364)
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end

