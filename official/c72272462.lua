--デスピアン・クエリティス
--Despian Quaeritis
--scripted by Rundas
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: 1 "Despia" monster + 1 LIGHT or DARK monster
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_DESPIA),aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_LIGHT|ATTRIBUTE_DARK))
	--Change the ATK of all monsters currently on the field to 0 until the end of this turn, except Level 8 or higher Fusion Monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	e1:SetCondition(function() return Duel.IsMainPhase() end)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--Add to your hand, or Special Summon, 1 "Fallen of Albaz" or 1 "Despia" monster, from your Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.thspcon)
	e2:SetTarget(s.thsptg)
	e2:SetOperation(s.thspop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_DESPIA}
s.listed_names={CARD_ALBAZ}
function s.atkfilter(c)
	return c:HasNonZeroAttack() and not (c:IsLevelAbove(8) and c:IsType(TYPE_FUSION))
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,tp,0)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g==0 then return end
	local c=e:GetHandler()
	for tc in g:Iter() do
		--Their ATK becomes 0 until the end of this turn
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end
function s.thspcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
end
function s.thspfilter(c,e,tp,mzone_chk)
	return (c:IsSetCard(SET_DESPIA) or c:IsCode(CARD_ALBAZ)) and c:IsMonster() and (c:IsAbleToHand()
		or (mzone_chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.thsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thspfilter,tp,LOCATION_DECK,0,1,nil,e,tp,Duel.GetLocationCount(tp,LOCATION_MZONE)>0) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.thspop(e,tp,eg,ep,ev,re,r,rp)
	local mzone_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local sc=Duel.SelectMatchingCard(tp,s.thspfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,mzone_chk):GetFirst()
	if not sc then return end
	aux.ToHandOrElse(sc,tp,
		function() return mzone_chk and sc:IsCanBeSpecialSummoned(e,0,tp,false,false) end,
		function() Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP) end,
		aux.Stringid(id,3)
	)
end
