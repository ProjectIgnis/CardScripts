--ダイナレッスル・レボリューション
--Dinowrestle Revolution
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddVrainsSkillProcedure(c,s.flipcon,s.flipop)
end
function s.ffilter(c,tp)
	return c:IsCode(90173539) and c:GetActivateEffect() and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--opd check
	if Duel.GetFlagEffect(tp,id)>0 then return false end
	--condition
	return Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_DECK,0,1,nil)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	--ask if you want to activate the skill or not
	if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	--opd register
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--check if skill is negated
	if aux.CheckSkillNegation(e,tp) then return end
	--Activate
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.ffilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		aux.PlayFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
	end
end
