--ダブルバイト
--Double Bite
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--skill
	aux.AddVrainsSkillProcedure(c,s.flipcon,s.flipop)
end
s.infilter=aux.FaceupFilter(Card.IsRace,RACE_INSECT)
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return (Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated()) and Duel.IsExistingMatchingCard(s.infilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	--opd check and ask if you want to activate the skill or not
	if Duel.GetFlagEffect(tp,id)>0 or not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	--opd register
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--check if skill is negated
	if aux.CheckSkillNegation(e,tp) then return end
	--Attack Twice
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectMatchingCard(tp,s.infilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end