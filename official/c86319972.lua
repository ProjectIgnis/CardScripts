--魔法名－「新しき世界の始まり」
--Magical Name - "Rosa Mundi"
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Banish 1 "Aleister" monster or 1 Fusion Monster from your GY; Special Summon 1 "Invoked" monster from your Extra Deck, ignoring its Summoning conditions, but banish it during the End Phase
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(s.extraspcost)
	e1:SetTarget(s.extrasptg)
	e1:SetOperation(s.extraspop)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--If a monster(s) is banished face-up, while this card is in your GY: You can banish this card, then target 1 of your banished "Invoked" monsters; Special Summon it
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET,EFFECT,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetCode(EVENT_REMOVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.banspcon)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.bansptg)
	e2:SetOperation(s.banspop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_ALEISTER,SET_INVOKED}
function s.extraspcostfilter(c,e,tp)
	return (c:IsSetCard(SET_ALEISTER) or c:IsFusionMonster()) and c:IsAbleToRemoveAsCost() and c:IsMonster() and aux.SpElimFilter(c,true)
		and Duel.IsExistingMatchingCard(s.extraspfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
function s.extraspfilter(c,e,tp,rc)
	return c:IsSetCard(SET_INVOKED) and Duel.GetLocationCountFromEx(tp,tp,rc,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.extraspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(-100)
	if chk==0 then return Duel.IsExistingMatchingCard(s.extraspcostfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.extraspcostfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.Remove(g,nil,REASON_COST)
end
function s.extrasptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local cost_chk=e:GetLabel()==-100
		e:SetLabel(0)
		return cost_chk or Duel.IsExistingMatchingCard(s.extraspfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_MZONE)
end
function s.extraspop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.extraspfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if sc and Duel.SpecialSummon(sc,0,tp,tp,true,false,POS_FACEUP)>0 then
		--Banish it during the End Phase
		aux.DelayedOperation(sc,PHASE_END,id,e,tp,function(ag) Duel.Remove(ag,POS_FACEUP,REASON_EFFECT) end,nil,0,0,aux.Stringid(id,2))
	end
end
function s.banspconfilter(c)
	return c:IsMonster() and c:IsFaceup() and c:IsLocation(LOCATION_REMOVED)
		and not c:IsPreviousLocation(LOCATION_SZONE)
end
function s.banspcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.banspconfilter,1,nil)
end
function s.banspfilter(c,e,tp)
	return c:IsSetCard(SET_INVOKED) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.bansptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.banspfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.banspfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.banspfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
end
function s.banspop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end