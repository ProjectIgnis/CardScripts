--闘魂
--Pain and Gain
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddVrainsSkillProcedure(c,s.flipcon,s.flipop)
end
s.listed_series={SET_GOUKI}
function s.gkfilter(c,tid)
	return c:IsSetCard(SET_GOUKI) and c:IsReason(REASON_BATTLE) and c:GetTurnID()==tid and c:IsPreviousSetCard(SET_GOUKI)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.HasFlagEffect(tp,id) then return false end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return false end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local g=Duel.GetMatchingGroup(s.gkfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED|LOCATION_EXTRA,0,nil,Duel.GetTurnCount())
	return #g>0 and ft>=#g and g:FilterCount(Card.IsCanBeSpecialSummoned,nil,e,0,tp,false,false)==#g
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	--Ask the player if they want to activate the Skill
	if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--This Skill can only be used once per Duel
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	--Check if the Skill is negated ("Anti Skill")
	if aux.CheckSkillNegation(e,tp) then return end
	--Special Summon all your "Gouki" monsters that were destroyed by battle this turn
	local g=Duel.GetMatchingGroup(s.gkfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED|LOCATION_EXTRA,0,nil,Duel.GetTurnCount()):Filter(Card.IsCanBeSpecialSummoned,nil,e,0,tp,false,false)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end