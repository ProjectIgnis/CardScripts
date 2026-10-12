--無垢なる絆 アルトメギア
--Ars Magna Artmage
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 2+ monsters, including an "Ars Magna" or "Artmage" monster
	Link.AddProcedure(c,nil,2,4,s.matcheck)
	--Your opponent cannot target your linked monsters with card effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c)
		return c:IsLinked()
	end)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	--During your Main Phase: You can add to your hand, or Special Summon, 1 "Ars Magna", "Artmage", "DoomZ", or "Elfnote" monster from your Deck, then if you have 3 or more different Monster Types on your field, you can Special Summon 1 monster from your GY or banishment. You can only use this effect of "Ars Magna Artmage" once per turn
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,0))
	e2a:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e2a:SetType(EFFECT_TYPE_IGNITION)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetCountLimit(1,id)
	e2a:SetCondition(aux.NOT(s.citrinitascon))
	e2a:SetTarget(s.thsptg)
	e2a:SetOperation(s.thspop)
	c:RegisterEffect(e2a)
	--Quick version if the effect of "Ars Magna - "Citrinitas"" is applying
	local e2b=e2a:Clone()
	e2b:SetType(EFFECT_TYPE_QUICK_O)
	e2b:SetCode(EVENT_FREE_CHAIN)
	e2b:SetCondition(s.citrinitascon)
	e2b:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e2b)
end
s.listed_series={SET_ARS_MAGNA,SET_ARTMAGE,SET_DOOMZ,SET_ELFNOTE}
s.material_setcode={SET_ARS_MAGNA,SET_ARTMAGE}
function s.matcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,{SET_ARS_MAGNA,SET_ARTMAGE},lc,sumtype,tp)
end
function s.citrinitascon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsPlayerAffectedByEffect(tp,EFFECT_ARS_MAGNA_CITRINITAS)
end
function s.thspfilter(c,e,tp,mmz_chk)
	return c:IsSetCard({SET_ARS_MAGNA,SET_ARTMAGE,SET_DOOMZ,SET_ELFNOTE}) and c:IsMonster() and (c:IsAbleToHand()
		or (mmz_chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.thsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mmz_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		return Duel.IsExistingMatchingCard(s.thspfilter,tp,LOCATION_DECK,0,1,nil,e,tp,mmz_chk)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.gybanspfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsFaceup()
end
function s.thspop(e,tp,eg,ep,ev,re,r,rp)
	local mmz_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local sc=Duel.SelectMatchingCard(tp,s.thspfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,mmz_chk):GetFirst()
	if not sc then return end
	aux.ToHandOrElse(sc,tp,
		function()
			return mmz_chk and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		end,
		function()
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end,
		aux.Stringid(id,2)
	)
	if not sc:IsLocation(LOCATION_HAND|LOCATION_MZONE) then return end
	if sc:IsLocation(LOCATION_HAND) then Duel.ShuffleHand(tp) end
	Duel.ShuffleDeck(tp)
	if Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil):GetBinClassCount(Card.GetRace)>=3 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.gybanspfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.gybanspfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.BreakEffect()
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end