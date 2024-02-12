--Kaibacorp Research
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
function s.tdfilter(c)
	return c:IsMonster() and c:IsAbleToDeckAsCost()
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and Duel.GetFlagEffect(tp,id)==0
		and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	--OPD register
	Duel.RegisterFlagEffect(tp,id,0,0,1)
	--Shuffle 1 monster back into Main Deck then send 1 card from hand to GY
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)>0 and g:GetFirst():IsLocation(LOCATION_DECK) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
		if Duel.SendtoGrave(sg,REASON_COST)>0 and sg:GetFirst():IsLocation(LOCATION_GRAVE) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_DRAW_COUNT)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(1,0)
			e1:SetValue(2)
			e1:SetReset(RESET_PHASE|PHASE_DRAW|RESET_SELF_TURN,1)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
