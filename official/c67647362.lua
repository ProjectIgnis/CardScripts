--海造賊－キャプテン黒髭
--Blackbeard, the Plunder Patroll Captain
--Scripted by ahtelel
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 2 monsters including a "Plunder Patroll" monster
	Link.AddProcedure(c,nil,2,2,s.matcheck)
	--Special Summon 1 "Plunder Patroll" monster from your Extra Deck with the same Attribute as a monster your opponent controls or is in their GY, and if you do, equip that target to it, then draw 1 card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_PLUNDER_PATROLL}
function s.matcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,SET_PLUNDER_PATROLL,lc,sumtype,tp)
end
function s.spfilter(c,e,tp,att)
	return c:IsSetCard(SET_PLUNDER_PATROLL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsAttribute,c:GetAttribute()),tp,0,LOCATION_MZONE|LOCATION_GRAVE,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsType(TYPE_EFFECT) and chkc:IsFaceup() end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsPlayerCanDraw(tp,1)
		and Duel.IsExistingTarget(aux.FaceupFilter(Card.IsType,TYPE_EFFECT),tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsType,TYPE_EFFECT),tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_EFFECT)
		and tc:IsControler(tp) and Duel.Equip(tp,tc,sc) then
		--Equip limit
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetValue(function(e,c) return c==sc end)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
