--Honey Trap
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--skill
	aux.AddVrainsSkillProcedure(c,s.flipcon,s.flipop,EVENT_BATTLE_DAMAGE)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return ep==tp and not Duel.GetAttackTarget() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and not Duel.IsPlayerAffectedByEffect(tp,EFFECT_CANNOT_SSET) and (Duel.GetLP(tp)>0 or Duel.IsPlayerAffectedByEffect(tp,EFFECT_CANNOT_LOSE_LP))
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
	--Recover and Set
	local rec=Duel.Recover(tp,ev,REASON_EFFECT)
	if rec~=ev or Duel.GetLocationCount(tp,LOCATION_SZONE)<1 or Duel.IsPlayerAffectedByEffect(tp,EFFECT_CANNOT_SSET) then return end
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	s.announce_filter={TYPE_TRAP,OPCODE_ISTYPE,TYPE_SKILL,OPCODE_ISTYPE,OPCODE_NOT,OPCODE_AND,TYPE_ACTION,OPCODE_ISTYPE,OPCODE_NOT,OPCODE_AND}
	local ac=Duel.AnnounceCard(tp,table.unpack(s.announce_filter))
	local tc=Duel.CreateToken(tp,ac)
	if tc:IsSSetable() then
		Duel.SSet(tp,tc)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetDescription(aux.Stringid(id,1))
		tc:RegisterEffect(e1)
	end
end