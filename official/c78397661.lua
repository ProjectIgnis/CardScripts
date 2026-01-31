--黒き竜のエクレシア
--Ecclesia and the Dark Dragon
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: 1 Tuner + 1+ non-Tuner monsters
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--Banish this card (until the End Phase), and if you do, Special Summon 1 "Fallen of Albaz" or 1 Level 4 or lower monster that mentions it from your Deck or GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(function() return Duel.IsMainPhase() end)
	e1:SetTarget(s.rmsptg)
	e1:SetOperation(s.rmspop)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e1)
	--Shuffle both 1 Level 8 Fusion Monster in your GY or banishment and 1 card on the field, and this card into the Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOEXTRA)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_ALBAZ}
function s.spfilter(c,e,tp)
	return (c:IsCode(CARD_ALBAZ) or (c:IsLevelBelow(4) and c:ListsCode(CARD_ALBAZ))) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.rmsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() and Duel.GetMZoneCount(tp,c)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.rmspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and aux.RemoveUntil(c,nil,REASON_EFFECT,PHASE_END,id,e,tp,aux.DefaultFieldReturnOp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function s.fustdfilter(c,e)
	return c:IsLevel(8) and c:IsFusionMonster() and c:IsFaceup() and c:IsAbleToExtra() and c:IsCanBeEffectTarget(e)
end
function s.fieldtdfilter(c,e)
	return c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtra()
		and Duel.IsExistingMatchingCard(s.fustdfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,c,e)
		and Duel.IsExistingMatchingCard(s.fieldtdfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,e) end
	local fusiong=Group.CreateGroup()
	local fieldg=Group.CreateGroup()
	repeat
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		fusiong=Duel.SelectMatchingCard(tp,s.fustdfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,c,e)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		fieldg=Duel.SelectMatchingCard(tp,s.fieldtdfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,true,nil,e)
	until fieldg~=nil
	local tg=fusiong:Merge(fieldg)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg+c,3,tp,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetTargetCards(e)
	if c:IsRelateToEffect(e) and #tg==2 then
		Duel.SendtoDeck(tg+c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end