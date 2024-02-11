--Battle City Siren
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
function s.posfilter(c)
	return c:IsMonster() and c:IsCanChangePosition()
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and Duel.GetFlagEffect(tp,id)==0 and Duel.GetFlagEffect(tp,id+100)<2
		and Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	--OPT register
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	--TPD register
	Duel.RegisterFlagEffect(tp,id+100,0,0,0)
	--Change battle position of 1 opponent's monster
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectMatchingCard(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
	if Duel.ChangePosition(g,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)>0 then
		--Must attack selected monster first
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_MUST_ATTACK)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCondition(s.atkcon)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetReset(RESET_PHASE|PHASE_END)
		g:GetFirst():RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_MUST_ATTACK_MONSTER)
		e2:SetValue(s.atkval)
		g:GetFirst():RegisterEffect(e2)
	end
end
function s.atkfilter(c)
	return c:IsMonster() and c:GetAttackAnnouncedCount()>0
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(s.atkfilter,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil) and e:GetHandler():GetAttackedCount()==0
end
function s.atkval(e,c)
	return c==e:GetHandler()
end