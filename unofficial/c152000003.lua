--バーニング・ドロー (スキル)
--Burning Draw (Skill)
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--skill
	aux.AddVrainsSkillProcedure(c,s.flipcon,s.flipop)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return Duel.GetLP(tp)>100 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=math.floor((Duel.GetLP(tp)-100)/1000)
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
	local dc=math.floor((Duel.GetLP(tp)-100)/1000)
	--Draw
	Duel.SetLP(tp,100)
	Duel.BreakEffect()
	Duel.Draw(tp,dc,REASON_EFFECT)
end