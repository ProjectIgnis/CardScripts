--No Mortal Can Resist
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--skill
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
s.listed_names={32274490}
function s.flipcon(e)
	local tp=e:GetHandlerPlayer()
	--condition
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_GRAVE,1,nil,TYPE_MONSTER) and Duel.GetFlagEffect(tp,id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--opd register
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	--Futile!
	local g=Duel.GetFieldGroup(1-tp,LOCATION_GRAVE,0):Filter(Card.IsType,nil,TYPE_MONSTER)
	for tc in aux.Next(g) do
		tc:Recreate(32274490)
	end
	Duel.ConfirmCards(tp,g,true)
end