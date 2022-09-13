--Viral Infection
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return aux.CanActivateSkill(tp)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local ct=Duel.DiscardHand(tp,aux.TRUE,1,60,REASON_EFFECT+REASON_DISCARD)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))
	if op==0 then
		g=Duel.SelectMatchingCard(1-tp,s.tgfilter,1-tp,LOCATION_DECK,0,ct,ct,nil,TYPE_MONSTER)
	elseif op==1 then
		g=Duel.SelectMatchingCard(1-tp,s.tgfilter,1-tp,LOCATION_DECK,0,ct,ct,nil,TYPE_SPELL)
	else
		g=Duel.SelectMatchingCard(1-tp,s.tgfilter,1-tp,LOCATION_DECK,0,ct,ct,nil,TYPE_TRAP)
	end
	if Duel.SendtoGrave(g,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SKILL_FLIP,tp,id|(2<<32))
	end
end
function s.tgfilter(c,ty)
	return c:IsType(ty) and c:IsAbleToGrave()
end