--不死なる太陽神
--The Immortal Sun God
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 "The Winged Dragon of Ra" monster from your GY or banishment, ignoring its Summoning conditions, then if you Special Summoned "The Winged Dragon of Ra" by this effect, send it to the GY, and if you do, you can Special Summon 1 "The Winged Dragon of Ra" monster from your Extra Deck. During the End Phase, send the monsters Special Summoned by this effect to the GY
	--Special Summon 1 "The Winged Dragon of Ra" monster from your GY or banishment, ignoring its Summoning conditions, then if you Special Summoned "The Winged Dragon of Ra" by this effect, you can send it to the GY, and if you do, Special Summon 1 "The Winged Dragon of Ra" monster from your Extra Deck. During the End Phase, send the monsters Special Summoned by this effect to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--During your Main Phase, if this card is in your GY: You can discard 1 "Sun God" card; add this card to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.Discard(function(c)
		return c:IsSetCard(SET_SUN_GOD)
	end))
	e2:SetTarget(s.rthtg)
	e2:SetOperation(s.rthop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_RA}
s.listed_series={SET_SUN_GOD,SET_THE_WINGED_DRAGON_OF_RA}
function s.gybanspfilter(c,e,tp)
	return c:IsSetCard(SET_THE_WINGED_DRAGON_OF_RA) and c:IsMonster() and c:IsFaceup()
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.gybanspfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_MZONE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.extraspfilter(c,e,tp,exc)
	return c:IsSetCard(SET_THE_WINGED_DRAGON_OF_RA) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,exc,c)>0
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.gybanspfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp):GetFirst()
	if sc and Duel.SpecialSummonStep(sc,0,tp,tp,true,false,POS_FACEUP)
		and sc:IsCode(CARD_RA) then
		Duel.SpecialSummonComplete()
		if sc:IsAbleToGrave() and Duel.IsExistingMatchingCard(s.extraspfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,sc)
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			if Duel.SendtoGrave(sc,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_GRAVE) then
				sc=nil
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				sc=Duel.SelectMatchingCard(tp,s.extraspfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
				if sc then
					Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	end
	if sc then
		--During the End Phase, send the monsters Special Summoned by this effect to the GY
		aux.DelayedOperation(sc,PHASE_END,id,e,tp,function(ag) Duel.SendtoGrave(ag,REASON_EFFECT) end,nil,0,0,aux.Stringid(id,3))
	end
	Duel.SpecialSummonComplete()
end
function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
end
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end