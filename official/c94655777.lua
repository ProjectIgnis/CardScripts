--闇征竜－ネビュラス
--Nebulous, Dragon Ruler of Shadows
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 2 of your banished "Dragon Ruler" monsters with different Attributes
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.rmspcost)
	e1:SetTarget(s.rmsptg)
	e1:SetOperation(s.rmspop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DRAGON_RULER)
	--Special Summon 1 "Eclepsis, Dragon Ruler of Woes" from your GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.gyspcost)
	e2:SetTarget(s.gysptg)
	e2:SetOperation(s.gyspop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_DRAGON_RULER}
s.listed_names={id,30350202} --"Eclepsis, Dragon Ruler of Woes"
function s.rmcostfilter(c)
	return (c:IsAttribute(ATTRIBUTE_DARK) or c:IsRace(RACE_DRAGON)) and c:IsDiscardable()
end
function s.rmspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() and Duel.IsExistingMatchingCard(s.rmcostfilter,tp,LOCATION_HAND,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,s.rmcostfilter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	Duel.SendtoGrave(g,REASON_COST|REASON_DISCARD)
end
function s.rmspfilter(c,e,tp)
	return c:IsSetCard(SET_DRAGON_RULER) and c:IsFaceup() and c:IsCanBeEffectTarget(e) and not c:IsCode(id)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.rmsptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.rmspfilter,tp,LOCATION_REMOVED,0,nil,e,tp)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>=2
		and g:GetClassCount(Card.GetAttribute)>=2 end
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dpcheck(Card.GetAttribute),1,tp,HINTMSG_SPSUMMON)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,2,tp,0)
end
function s.rmspop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	local tg=Duel.GetTargetCards(e)
	if #tg==0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and #tg>1 then return end
	if #tg>ft then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		tg=tg:Select(tp,ft,ft,nil)
	end
	local c=e:GetHandler()
	for tc in tg:Iter() do
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			--It cannot attack this turn
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(3206)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
	Duel.SpecialSummonComplete()
end
function s.gyspcostfilter(c,e,tp)
	return (c:IsAttribute(ATTRIBUTE_DARK) or c:IsRace(RACE_DRAGON)) and c:IsAbleToRemoveAsCost()
		and Duel.IsExistingTarget(s.gyspfilter,tp,LOCATION_GRAVE,0,1,c,e,tp)
end
function s.gyspfilter(c,e,tp)
	return c:IsCode(30350202) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.gyspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(s.gyspcostfilter,tp,LOCATION_GRAVE,0,1,c,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.gyspcostfilter,tp,LOCATION_GRAVE,0,1,1,c,e,tp)
	g:AddCard(c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.gysptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.gyspfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.gyspfilter,tp,LOCATION_GRAVE,0,1,c,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.gyspfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
end
function s.gyspop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end