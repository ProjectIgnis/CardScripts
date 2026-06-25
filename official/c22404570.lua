--終刻なる獄神影
--Power Patron Shadows of the End Times
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 "Power Patron" monster from your hand, face-up Extra Deck, or GY, then you can apply any of these effects, in sequence, based on the number of different card types (Fusion, Synchro, Xyz) you control
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
end
s.listed_series={SET_POWER_PATRON}
function s.spfilter(c,e,tp)
	if not (c:IsSetCard(SET_POWER_PATRON) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	if c:IsLocation(LOCATION_HAND|LOCATION_GRAVE) then
		return Duel.GetMZoneCount(tp)>0
	elseif c:IsLocation(LOCATION_EXTRA) then
		return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_EXTRA|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_EXTRA|LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_DECK|LOCATION_ONFIELD|LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_EXTRA|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		local card_type_count=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsMonster),tp,LOCATION_MZONE,0,nil):GetBinClassCount(function(c) return c:GetType()&(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ) end)
		if card_type_count==0 then return end
		local opp=1-tp
		local break_chk=false
		local opp_decktop3=Duel.GetDecktopGroup(opp,3)
		local opp_field=Duel.GetFieldGroup(opp,LOCATION_ONFIELD,0)
		local opp_hand=Duel.GetFieldGroup(opp,LOCATION_HAND,0)
		--● 1+: Banish (face-down) the top 3 cards of your opponent's Deck
		if card_type_count>=1 and #opp_decktop3==3 and opp_decktop3:FilterCount(Card.IsAbleToRemove,nil,tp,POS_FACEDOWN)==3
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.DisableShuffleCheck()
			Duel.BreakEffect()
			if Duel.Remove(opp_decktop3,POS_FACEDOWN,REASON_EFFECT)>0 then break_chk=true end
		end
		--● 2+: Banish (face-down) 1 card your opponent controls
		if card_type_count>=2 and #opp_field>0 and opp_field:IsExists(Card.IsAbleToRemove,1,nil,tp,POS_FACEDOWN)
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local g=opp_field:FilterSelect(tp,Card.IsAbleToRemove,1,1,nil,tp,POS_FACEDOWN)
			if #g>0 then
				Duel.HintSelection(g)
				if break_chk then Duel.BreakEffect() end
				if Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)>0 then break_chk=true end
			end
		end
		--● 3: Banish (face-down) 1 random card from your opponent's hand
		if card_type_count==3 and #opp_hand>0 and opp_hand:IsExists(Card.IsAbleToRemove,1,nil,tp,POS_FACEDOWN)
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			local g=opp_hand:Match(Card.IsAbleToRemove,nil,tp,POS_FACEDOWN):RandomSelect(tp,1)
			if #g>0 then
				if break_chk then Duel.BreakEffect() end
				Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
			end
		end
	end
end