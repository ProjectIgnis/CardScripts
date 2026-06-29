--躯売りのカラス
--Corpse-Seller Crow
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Send cards from the top of your Deck to the GY up to the number of Traps in the GYs with different names +1 (max. 4), then you can apply 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_SET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
end
s.listed_names={id}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SET,nil,1,tp,LOCATION_GRAVE)
end
function s.setfilter(c)
	return c:IsSpellTrap() and c:IsSSetable() and not c:IsCode(id)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	local trap_count=Duel.GetMatchingGroup(Card.IsTrap,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil):GetClassCount(Card.GetCode)+1
	local deck_count=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	local max_count=math.min(trap_count,deck_count,4)
	local mill_count=1
	if max_count>1 then
		mill_count=Duel.AnnounceNumberRange(tp,1,max_count)
	end
	if Duel.DiscardDeck(tp,mill_count,REASON_EFFECT)==0 then return end
	local og=Duel.GetOperatedGroup():Match(Card.IsLocation,nil,LOCATION_GRAVE)
	if #og==0 then return end
	--● Special Summon 1 of the monsters sent to the GY
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and og:IsExists(aux.NecroValleyFilter(Card.IsCanBeSpecialSummoned),1,nil,e,0,tp,false,false)
	--● Set 1 of the Spells/Traps sent to the GY, except "Corpse-Seller Crow", and if you Set a Trap or Quick-Play Spell, it can be activated this turn
	local b2=og:IsExists(aux.NecroValleyFilter(s.setfilter),1,nil)
	if not ((b1 or b2) and Duel.SelectYesNo(tp,aux.Stringid(id,1))) then return end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	if op==1 then
		--● Special Summon 1 of the monsters sent to the GY
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=og:FilterSelect(tp,aux.NecroValleyFilter(Card.IsCanBeSpecialSummoned),1,1,nil,e,0,tp,false,false)
		if #g>0 then
			Duel.BreakEffect()
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif op==2 then
		--● Set 1 of the Spells/Traps sent to the GY, except "Corpse-Seller Crow", and if you Set a Trap or Quick-Play Spell, it can be activated this turn
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local sc=og:FilterSelect(tp,aux.NecroValleyFilter(s.setfilter),1,1,nil):GetFirst()
		if not sc then return end
		Duel.BreakEffect()
		if Duel.SSet(tp,sc)>0 and (sc:IsTrap() or sc:IsQuickPlaySpell()) then
			local eff_code=sc:IsTrap() and EFFECT_TRAP_ACT_IN_SET_TURN or EFFECT_QP_ACT_IN_SET_TURN
			--It can be activated this turn
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,4))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(eff_code)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			sc:RegisterEffect(e1)
		end
	end
end