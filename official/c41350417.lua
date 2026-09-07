--黒魔導のカーテン
--Dark Magical Curtain
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Each player can Special Summon 1 DARK Spellcaster monster from their hand or Deck (but neither player can activate their effects this turn), then if you Special Summoned a monster whose original name is "Dark Magician" or "Dark Magician Girl", you can add 1 Spell/Trap that mentions "Dark Magician" from your Deck to your hand, except "Dark Magical Curtain"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_DARK_MAGICIAN,CARD_DARK_MAGICIAN_GIRL,id}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_EITHER,LOCATION_HAND|LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.spfilter(c,e,sp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,sp,false,false,POS_FACEUP,sp)
end
function s.spresolution(e,sp)
	local name_chk=false
	if Duel.GetLocationCount(sp,LOCATION_MZONE,sp)>0
		and Duel.IsExistingMatchingCard(s.spfilter,sp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,sp)
		and Duel.SelectYesNo(sp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,sp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(sp,s.spfilter,sp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,sp):GetFirst()
		if sc and Duel.SpecialSummonStep(sc,0,sp,sp,false,false,POS_FACEUP) then
			name_chk=sc:IsOriginalCodeRule(CARD_DARK_MAGICIAN,CARD_DARK_MAGICIAN_GIRL)
			--Neither player can activate their effects this turn
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(3302)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_TRIGGER)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			sc:RegisterEffect(e1)
		end
	end
	return name_chk
end
function s.thfilter(c)
	return c:IsSpellTrap() and c:ListsCode(CARD_DARK_MAGICIAN) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local turn_player=Duel.GetTurnPlayer()
	local non_turn_player=1-turn_player
	local turn_player_name_chk=s.spresolution(e,turn_player)
	local non_turn_player_name_chk=s.spresolution(e,non_turn_player)
	if Duel.SpecialSummonComplete()==0 then return end
	if not ((turn_player_name_chk and tp==turn_player) or (non_turn_player_name_chk and tp==non_turn_player)) then return end
	if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.BreakEffect()
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end