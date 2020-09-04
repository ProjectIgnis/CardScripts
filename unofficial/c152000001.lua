--闘魂
--Pain and Gain
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--skill
	aux.AddVrainsSkillProcedure(c,s.flipcon,s.flipop)
end
s.listed_series={0xfc}
function s.gkfilter(c,e,tp,tid)
	return c:IsReason(REASON_BATTLE) and c:GetTurnID()==tid and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp) and c:IsSetCard(0xfc)
end
function s.gkfilter(c,tid)
	return c:IsReason(REASON_BATTLE) and c:GetTurnID()==tid and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSetCard(0xfc)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return false end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local g=Duel.GetMatchingGroup(s.gkfilter,tp,LOCATION_ALL-LOCATION_MZONE,0,nil,Duel.GetTurnCount())
	return #g>0 and ft>=#g and g:FilterCount(Card.IsCanBeSpecialSummoned,nil,e,0,tp,false,false,POS_FACEUP,tp)==#g
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	--opd check and ask if you want to activate the skill or not
	if Duel.GetFlagEffect(tp,id)>0 or not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	--opd register
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--check if skill is negated
	if aux.CheckSkillNegation(e,tp) then return end
	--Special Summon
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local g=Duel.GetMatchingGroup(s.gkfilter,tp,LOCATION_ALL-LOCATION_MZONE,0,nil,Duel.GetTurnCount())
	if not (#g>0 and ft>=#g and g:FilterCount(Card.IsCanBeSpecialSummoned,nil,e,0,tp,false,false,POS_FACEUP,tp)==#g) then return end
	Duel.HintSelection(g)
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
