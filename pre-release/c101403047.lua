--無垢なる協奏 エルフェンノーツ
--Ars Magna Elfnote
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 2 monsters, including an "Ars Magna" or "Elfnote" monster
	Link.AddProcedure(c,nil,2,2,s.matcheck)
	--Your linked monsters gain 300 ATK for each different Monster Type on the field
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c)
		return c:IsLinked()
	end)
	e1:SetValue(function(e,c)
		return 300*Duel.GetMatchingGroup(Card.IsFaceup,0,LOCATION_MZONE,LOCATION_MZONE,nil):GetBinClassCount(Card.GetRace)
	end)
	c:RegisterEffect(e1)
	--During your Main Phase: You can send to the GY, or banish, 1 card you control, then you can return 1 monster on the field to the hand
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,0))
	e2a:SetCategory(CATEGORY_TOGRAVE+CATEGORY_REMOVE+CATEGORY_TOHAND)
	e2a:SetType(EFFECT_TYPE_IGNITION)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetCountLimit(1,{id,0})
	e2a:SetCondition(aux.NOT(s.citrinitascon))
	e2a:SetTarget(s.tgbantg)
	e2a:SetOperation(s.tgbanop)
	c:RegisterEffect(e2a)
	--Quick version if the effect of "Ars Magna - "Citrinitas"" is applying
	local e2b=e2a:Clone()
	e2b:SetType(EFFECT_TYPE_QUICK_O)
	e2b:SetCode(EVENT_FREE_CHAIN)
	e2b:SetCondition(s.citrinitascon)
	e2b:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e2b)
	--You can banish this card from your GY; Special Summon 1 "Elfnote" monster from your hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(Cost.SelfBanish)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_ARS_MAGNA,SET_ELFNOTE}
s.material_setcode={SET_ARS_MAGNA,SET_ELFNOTE}
function s.matcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,{SET_ARS_MAGNA,SET_ELFNOTE},lc,sumtype,tp)
end
function s.citrinitascon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsPlayerAffectedByEffect(tp,EFFECT_ARS_MAGNA_CITRINITAS)
end
function s.tgbantg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.OR(Card.IsAbleToGrave,Card.IsAbleToRemove),tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_ONFIELD)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,PLAYER_EITHER,LOCATION_MZONE)
end
function s.tgbanop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local sc=Duel.SelectMatchingCard(tp,aux.OR(Card.IsAbleToGrave,Card.IsAbleToRemove),tp,LOCATION_ONFIELD,0,1,1,nil):GetFirst()
	if not sc then return end
	Duel.HintSelection(sc)
	local option_1=sc:IsAbleToGrave()
	local option_2=sc:IsAbleToRemove()
	local choice=Duel.SelectEffect(tp,
		{option_1,aux.Stringid(id,3)},
		{option_2,aux.Stringid(id,4)})
	if (choice==1 and Duel.SendtoGrave(sc,REASON_EFFECT)>0) or (choice==2 and Duel.Remove(sc,POS_FACEUP,REASON_EFFECT)>0) then
		if choice==1 and not sc:IsLocation(LOCATION_GRAVE) then return end
		if choice==2 and not (sc:IsLocation(LOCATION_REMOVED) or sc:IsType(TYPE_TOKEN)) then return end
		if Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
			local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
			if #g>0 then
				Duel.HintSelection(g)
				Duel.BreakEffect()
				Duel.SendtoHand(g,nil,REASON_EFFECT)
			end
		end
	end
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_ELFNOTE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end