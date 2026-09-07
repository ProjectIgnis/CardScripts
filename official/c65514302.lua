--マグネット・ボンディング
--Magnet Bonding
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects (but you can only use each effect of "Magnet Bonding" once per turn)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(function() return Duel.IsMainPhase() end)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e1)
end
s.listed_names={44839512} --"Conduction Warrior Linear Magnum ±"
s.listed_series={SET_MAGNET_WARRIOR,SET_MAGNA_WARRIOR}
function s.magnetthfilter(c)
	return (c:IsCode(44839512) or (c:IsLevelBelow(4) and c:IsSetCard(SET_MAGNET_WARRIOR))) and c:IsAbleToHand()
end
function s.magnathfilter(c)
	return c:IsLevel(8) and c:IsSetCard(SET_MAGNA_WARRIOR) and c:IsAbleToHand()
end
function s.fextrafilter(c)
	return c:IsRace(RACE_ROCK) and c:IsFaceup() and c:IsAbleToDeck()
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(s.fextrafilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	--Add 1 "Conduction Warrior Linear Magnum ±" or 1 Level 4 or lower "Magnet Warrior" monster from your Deck to your hand
	local b1=not Duel.HasFlagEffect(tp,id)
		and Duel.IsExistingMatchingCard(s.magnetthfilter,tp,LOCATION_DECK,0,1,nil)
	--Add 1 Level 8 "Magna Warrior" monster from your Deck to your hand
	local b2=not Duel.HasFlagEffect(tp,id+1)
		and Duel.IsExistingMatchingCard(s.magnathfilter,tp,LOCATION_DECK,0,1,nil)
	--Fusion Summon 1 Rock Fusion Monster from your Extra Deck, by shuffling Rock monsters from your hand, field, GY, and/or banishment into the Deck
	local fusion_params={
			fusfilter=function(c) return c:IsRace(RACE_ROCK) end,
			matfilter=function(c) return c:IsRace(RACE_ROCK) and c:IsAbleToDeck() end,
			extrafil=s.fextra,
			extraop=Fusion.ShuffleMaterial
		}
	local b3=not Duel.HasFlagEffect(tp,id+2)
		and Fusion.SummonEffTG(fusion_params)(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return b1 or b2 or b3 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b3,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif op==3 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TODECK)
		Duel.RegisterFlagEffect(tp,id+2,RESET_PHASE|PHASE_END,0,1)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Add 1 "Conduction Warrior Linear Magnum ±" or 1 Level 4 or lower "Magnet Warrior" monster from your Deck to your hand
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.magnetthfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	elseif op==2 then
		--Add 1 Level 8 "Magna Warrior" monster from your Deck to your hand
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.magnathfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	elseif op==3 then
		--Fusion Summon 1 Rock Fusion Monster from your Extra Deck, by shuffling Rock monsters from your hand, field, GY, and/or banishment into the Deck
		local fusion_params={
			fusfilter=function(c) return c:IsRace(RACE_ROCK) end,
			matfilter=function(c) return c:IsRace(RACE_ROCK) and c:IsAbleToDeck() end,
			extrafil=s.fextra,
			extraop=Fusion.ShuffleMaterial
		}
		Fusion.SummonEffOP(fusion_params)(e,tp,eg,ep,ev,re,r,rp)
	end
end