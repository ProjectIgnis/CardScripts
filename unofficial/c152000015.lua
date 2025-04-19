--アンチスキル
--Anti Skill
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--skill
	aux.AddVrainsSkillProcedure(c,s.flipcon,s.flipop,EFFECT_NEGATE_SKILL)
end
function s.flipcon(e)
	--condition
	return Duel.IsPlayerCanDraw(e:GetHandlerPlayer(),2)
end
function s.flipop(e,tp,re)
	--opd check and ask if you want to activate the skill or not
	if Duel.GetFlagEffect(tp,id)>0 or not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
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