--ジェム・エンハンス
--Gem-Enhancement
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_ATTACK,TIMING_ATTACK)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_GEM_KNIGHT}
function s.cfilter(c)
	return c:IsSetCard(SET_GEM_KNIGHT)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,aux.ReleaseCheckMMZ,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,false,aux.ReleaseCheckMMZ,nil)
	Duel.Release(g,REASON_COST)
end
function s.filter(c,e,tp)
	return c:IsSetCard(SET_GEM_KNIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc,e,tp) end
	if chk==0 then
		if e:GetLabel()==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		e:SetLabel(0)
		return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	e:SetLabel(0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end