--Blaze Accelerator Deployment
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
end
s.listed_names={69537999,21420702}
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and Duel.GetFlagEffect(ep,id)<2
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,69537999),tp,LOCATION_SZONE,0,1,nil)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--TPD Register
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	--Change "Blaze Accelerator" to "Tri-Blaze Accelerator"
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local tc=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsCode,69537999),tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(21420702)
	tc:RegisterEffect(e1)
end