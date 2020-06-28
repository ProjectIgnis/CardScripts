--アンチスキル
--Anti Skill
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--skill
	aux.AddVrainsSkillProcedure(c,s.flipcon,s.flipop,EFFECT_NEGATE_SKILL)
end
function s.flipcon(e,tp,re)
	--opd check
	if Duel.GetFlagEffect(tp,id)>0 then return false end
	--condition
	return Duel.IsPlayerCanDraw(tp,2)
end
function s.flipop(e,tp,re)
	--ask if you want to activate the skill or not
	if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return false end
	--opd register
	Duel.RegisterFlagEffect(tp,id,0,0,0) 
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--check if skill is negated
	if aux.CheckSkillNegation(e,tp) then
		return false
	end
	if Duel.Draw(tp,2,REASON_EFFECT)==2 then
		return true
	end
	return false
end
