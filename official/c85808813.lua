--タイム・ストリーム
--Time Stream
--Logical Nonsense
local s,id=GetID()
function s.initial_effect(c)
	--Tribute 1 "Fossil" Fusion Monster and Special Summon 1 "Fossil" Fusion Monster whose original Level is 2 higher
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RELEASE+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Special Summon 1 "Fossil" Fusion Monster from your GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(aux.exccon)
	e2:SetCost(s.gyspcost)
	e2:SetTarget(s.gysptg)
	e2:SetOperation(s.gyspop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_FOSSIL}
s.listed_names={CARD_FOSSIL_FUSION}
function s.trbfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsSetCard(SET_FOSSIL) and c:IsReleasableByEffect()
		and Duel.IsExistingMatchingCard(s.exspfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetOriginalLevel(),c)
end
function s.exspfilter(c,e,tp,lv,mc)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(SET_FOSSIL) and c:GetOriginalLevel()==lv+2
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,true,true)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.trbfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.trbfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectTarget(tp,s.trbfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and Duel.Release(tc,REASON_EFFECT)>0) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.exspfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc:GetOriginalLevel()):GetFirst()
	if not sc then return end
	sc:SetMaterial(nil)
	if Duel.SpecialSummon(sc,SUMMON_TYPE_FUSION,tp,tp,true,true,POS_FACEUP)>0 then
		sc:CompleteProcedure()
	end
end
function s.costfilter(c,e,tp)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(SET_FOSSIL) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
		and Duel.IsExistingTarget(s.gyspfilter,tp,LOCATION_GRAVE,0,1,c,e,tp)
end
function s.gyspfilter(c,e,tp)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(SET_FOSSIL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.gyspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.Remove(g+c,POS_FACEUP,REASON_COST)
end
function s.gysptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.gyspfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.gyspfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
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