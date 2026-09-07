--Ultimate Wizardry
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
s.counter_place_list={COUNTER_SPELL}
function s.spcounterfilter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsRace(RACE_SPELLCASTER)and c:IsCanAddCounter(COUNTER_SPELL,1)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.spcounterfilter,tp,LOCATION_MZONE,0,nil)
	return aux.CanActivateSkill(tp) and #g>0 and Duel.GetFlagEffect(tp,id+100)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local g=Duel.GetMatchingGroup(s.spcounterfilter,tp,LOCATION_MZONE,0,nil)
	--Place 1 Spell Counter on all Spellcaster monsters you control that you can place a Spell Counter on (initial activation)
	if Duel.GetFlagEffect(tp,id)==0 and #g>0 then 
		for tc in g:Iter() do
			tc:AddCounter(COUNTER_SPELL,1)
		end	 
		Duel.RegisterFlagEffect(tp,id,0,0,0)
	--Place 1 Spell Counter on 1 Spellcaster monster you control that you can place a Spell Counter on (subsequent activations)
	elseif Duel.GetFlagEffect(tp,id)>0 and Duel.GetFlagEffect(tp,id+100)==0 and #g>0 then
		local sc=g:Select(tp,1,1,nil):GetFirst()
		if sc then
			sc:AddCounter(COUNTER_SPELL,1)
		end
		Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE|PHASE_END,0,1)
	end
end
