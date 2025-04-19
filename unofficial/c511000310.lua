--ドクターＤ
--Doctor D (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 "Destiny Hero" monster from the GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function s.costfilter(c,e,tp)
	return c:IsMonster() and c:IsSetCard(SET_DESTINY_HERO) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
		and Duel.GetMZoneCount(tp,c)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,c,e,tp)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_DESTINY_HERO) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local chkcost=e:GetLabel()==1 and true or false
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then
		if chkcost then
			e:SetLabel(0)
			return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil,e,tp)
		else
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		end
	end
	if chkcost then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil,e,tp)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end