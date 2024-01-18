--Now You See Them...
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
s.listed_names={CARD_DARK_MAGICIAN}
function s.tdfilter(c)
	return c:IsCode(CARD_DARK_MAGICIAN) and c:IsAbleToDeckAsCost()
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and Duel.GetFlagEffect(tp,id)==0
		and Duel.IsExistingMatchingCard(aux.NOT(Card.IsPublic),tp,LOCATION_HAND,0,1,nil)
		and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_HAND,0,2,nil)
		and Duel.IsPlayerCanDraw(tp,1)
end
function s.rescon(sg,e,tp,mg)
	local d1=Duel.IsPlayerCanDraw(tp,1) and sg:FilterCount(s.tdfilter,nil)==1
	local d2=Duel.IsPlayerCanDraw(tp,3) and sg:FilterCount(s.tdfilter,nil)==2
	local d3=Duel.IsPlayerCanDraw(tp,5) and sg:FilterCount(s.tdfilter,nil)==3
	return (d1 or d2 or d3)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	--OPD register
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	--Reveal hand, send DM to bottom of Decks, then draw 1
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	Duel.ConfirmCards(1-tp,g)
	g:Filter(s.tdfilter,nil)
	local hg=aux.SelectUnselectGroup(g,e,tp,1,3,s.rescon,1,tp,HINTMSG_TODECK)
	local dg=Duel.SendtoDeck(hg,nil,SEQ_DECKBOTTOM,REASON_COST)
	if dg==1 then
		Duel.Draw(tp,1,REASON_EFFECT)
	elseif dg==2 then
		Duel.Draw(tp,3,REASON_EFFECT)
	elseif dg==3 then
		Duel.Draw(tp,5,REASON_EFFECT)
	end
end