--ロック・ユー
--Stalactite Spear
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--skill
	aux.AddVrainsSkillProcedure(c,s.flipcon,s.flipop,EVENT_BATTLE_DESTROYING)
end 
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	local tc=eg:GetFirst()
	local bc=tc:GetBattleTarget()
	return tc:IsRelateToBattle() and tc:IsStatus(STATUS_OPPO_BATTLE) and tc:IsControler(tp) and tc:IsAttribute(ATTRIBUTE_EARTH)
		and bc:IsReason(REASON_BATTLE) and bc:GetPreviousControler()==1-tp and bc:GetLevel()>0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	--opd check and ask if you want to activate the skill or not
	if Duel.GetFlagEffect(tp,id)>0 or not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	--opd register
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Check if Skill is negated
	if aux.CheckSkillNegation(e,tp) then return end
	--Damage
	local tc=eg:GetFirst()
	local bc=tc:GetBattleTarget()
	if tc:IsRelateToBattle() and tc:IsStatus(STATUS_OPPO_BATTLE) and tc:IsControler(tp) and tc:IsAttribute(ATTRIBUTE_EARTH) and bc:IsReason(REASON_BATTLE) and bc:GetPreviousControler()~=tp and bc:GetLevel()>0 then
		local dam=bc:GetLevel()*100
		Duel.Damage(1-tp,dam,REASON_EFFECT)
	end
end