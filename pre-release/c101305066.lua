--三幻魔合殺
--Destruction Chant of the Sacred Beast
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 "Sacred Beast" monster from your hand or GY in Defense Position, then if you control 2 or more "Sacred Beast" monsters whose original Levels are 10, you can negate the effects of 1 face-up card your opponent controls, and if you do, destroy it
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--You can banish this card from your GY; Fusion Summon 1 "Phantasm" Fusion Monster from your Extra Deck, using monsters from your hand or field
	local fusion_params={aux.FilterBoolFunction(Card.IsSetCard,SET_PHANTASM)}
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(Fusion.SummonEffTG(fusion_params))
	e2:SetOperation(Fusion.SummonEffOP(fusion_params))
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SACRED_BEAST,SET_PHANTASM}
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_SACRED_BEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,true,POS_FACEUP_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
	local dg=Duel.GetMatchingGroup(Card.IsNegatable,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DISABLE,dg,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,dg,1,tp,0)
end
function s.sacredbeastfilter(c)
	return c:IsSetCard(SET_SACRED_BEAST) and c:IsOriginalLevel(10) and c:IsFaceup()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,true,POS_FACEUP_DEFENSE)>0
		and Duel.IsExistingMatchingCard(s.sacredbeastfilter,tp,LOCATION_MZONE,0,2,nil)
		and Duel.IsExistingMatchingCard(Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
		local sc=Duel.SelectMatchingCard(tp,Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,1,nil):GetFirst()
		if not sc then return end
		Duel.HintSelection(sc)
		if sc:IsCanBeDisabledByEffect(e) then
			Duel.BreakEffect()
			--Negate the effects of 1 face-up card your opponent controls, and if you do, destroy it
			sc:NegateEffects(e:GetHandler(),RESET_EVENT|RESETS_STANDARD,true)
			Duel.AdjustInstantly(sc)
			if sc:IsDisabled() then
				Duel.Destroy(sc,REASON_EFFECT)
			end
		end
	end
end