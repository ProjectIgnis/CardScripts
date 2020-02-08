--ハイパー・ギャラクシー
--Hyper Galaxy
--Logical Nonsense

--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Tribute opponent's monster, special summon "Galaxy-Eyes Photon Dragon"
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
	--Contains "Galaxy-Eyes Photon Dragon" in text
s.listed_names={CARD_GALAXYEYES_P_DRAGON}

	--Check for a monster with 2000+ ATK, besides "Galaxy-Eyes Photon Dragon"
function s.costfilter(c,ft,tp)
	return (c:IsControler(tp) or c:IsFaceup()) and c:IsAttackAbove(2000) and not c:IsCode(CARD_GALAXYEYES_P_DRAGON) and (ft>0 or c:GetSequence()<5)
		and Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,c,e)
end
	--Tribute cost
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroupCost(tp,s.costfilter,1,false,aux.ReleaseCheckMMZ,nil,ft,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectReleaseGroupCost(tp,s.costfilter,1,1,false,aux.ReleaseCheckMMZ,nil,ft,tp)
	Duel.Release(g,REASON_COST)
end
	--Opponent's monster with 2000+ ATK and can be tributed
function s.filter(c,e)
	return c:IsFaceup() and c:IsAttackAbove(2000) and c:IsReleasableByEffect(e)
end
	--Check for "Galaxy-Eyes Photon Dragon"
function s.spfilter(c,e,tp)
	return c:IsCode(CARD_GALAXYEYES_P_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
	--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc,e) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil,e)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
	--Tribute opponent's monster, special summon "Galaxy-Eyes Photon Dragon"
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.Release(tc,REASON_EFFECT)~=0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
