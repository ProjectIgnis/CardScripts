--Three-Star Demotion
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--skill
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
s.listed_names={98434877,62340868,25955164}
function s.filter(c)
	return c:IsCode(98434877) or c:IsCode(62340868) or c:IsCode(25955164)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--opd check
	if Duel.GetFlagEffect(ep,id)>0 then return end
	--condition
	local b1=Duel.GetLP(tp)<=1000 and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_HAND,0,1,nil,TYPE_MONSTER)
	local b2=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil)
	return aux.CanActivateSkill(tp) and (b1 or b2)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--opd register
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	--Three-Star Demotion
	local b1=Duel.GetLP(tp)<=1000 and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_HAND,0,1,nil,TYPE_MONSTER)
	local b2=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil)
	if b1 then
		local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_HAND,0,nil,TYPE_MONSTER)
		for tc in aux.Next(g) do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetValue(-3)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	elseif b2 then
		local gg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND,0,nil)
		for tc in aux.Next(gg) do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetValue(-3)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)  
		end
	end
end
