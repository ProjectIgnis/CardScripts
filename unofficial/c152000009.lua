--トリックスター・ギグ
--Trickstar Gig
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddVrainsSkillProcedure(c,s.flipcon,s.flipop)
end
s.listed_series={0xfb}
function s.tkfilter(c)
	return c:IsSetCard(SET_TRICKSTAR) and c:IsAbleToHand()
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	local fgc=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,SET_TRICKSTAR),tp,LOCATION_MZONE,0,nil)
	return fgc>0 and Duel.IsPlayerCanDiscardDeck(tp,fgc) and Duel.IsExistingMatchingCard(s.tkfilter,tp,LOCATION_GRAVE,0,1,nil)
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
	--Deck Des/Add to hand
	local fgc=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,SET_TRICKSTAR),tp,LOCATION_MZONE,0,nil)
	if fgc>0 and Duel.IsPlayerCanDiscardDeck(tp,fgc) and Duel.DiscardDeck(tp,fgc,REASON_EFFECT)>0
		and Duel.IsExistingMatchingCard(s.tkfilter,tp,LOCATION_GRAVE,0,1,nil) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local thg=Duel.SelectMatchingCard(tp,s.tkfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.HintSelection(thg)
		Duel.SendtoHand(thg,tp,REASON_EFFECT)
	end
end