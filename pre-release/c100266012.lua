--タイム・ストリーム
--Time Stream
--Logical Nonsense

--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Tribute 1 "Fossil" fusion, and if you do, special summon another, 2 levels higher
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RELEASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Special summon 1 "Fossil" fusion from GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(aux.exccon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
	--Lists "Fossil" archetype
s.listed_series={0x243}
	--Specifically lists "Fossil Fusion"
s.listed_names={CARD_FOSSIL_FUSION}

	--Check for "Fossil" fusion monster to tribute
function s.filter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsSetCard(0x243) and c:IsReleasableByEffect()
	 and Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_EXTRA,0,1,nil,c:GetLevel(),e,tp)
end
	--Check for "Fossil" fusion monster with 2 levels higher than one in "filter"
function s.ssfilter(c,lv,e,tp)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x243) and c:IsLevel(lv+2)
	 and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,true,POS_FACEUP)
end
	--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
	--Tribute 1 "Fossil" fusion, and if you do, special summon another, 2 levels higher
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		if Duel.Release(tc,REASON_EFFECT)==0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.ssfilter,tp,LOCATION_EXTRA,0,1,1,nil,tc:GetLevel(),e,tp)
		if #sg>0 then 
			Duel.SpecialSummonStep(sg:GetFirst(),0,tp,tp,true,true,POS_FACEUP)
		end
	end
end
	--Check for "Fossil" fusion to banish
function s.cfilter(c,e,tp)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x243) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true) 
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,c,e,tp)
end
	--Check for "Fossil" fusion to special summon
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x243) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
	--Banish this card and 1 "Fossil" fusion as cost
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,e,tp)
	g:AddCard(e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
	--Activation legality
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
	--Special summon 1 "Fossil" fusion from GY
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
