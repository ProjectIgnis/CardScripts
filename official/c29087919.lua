--ギアギアチェンジ
--Geargia Change
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 2 or more "Geargiano" monsters with different names from your GY and Xyz Summon 1 Xyz Monster using the Summoned monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_GEARGIANO}
function s.gyspfilter(c,e,tp)
	return c:IsSetCard(SET_GEARGIANO) and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.extraspfilter(c,mg)
	return c:IsXyzSummonable(nil,mg,2,#mg)
end
function s.rescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetCode)==#sg and Duel.IsExistingMatchingCard(s.extraspfilter,tp,LOCATION_EXTRA,0,1,nil,sg)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local mg=Duel.GetMatchingGroup(s.gyspfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	local maxct=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),mg:GetClassCount(Card.GetCode))
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and maxct>=2 and aux.SelectUnselectGroup(mg,e,tp,2,maxct,s.rescon,0) end
	local sg=aux.SelectUnselectGroup(mg,e,tp,2,maxct,s.rescon,1,tp,HINTMSG_SPSUMMON)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,#sg,tp,0)
end
function s.xyzfilter(c,mg,ct)
	return c:IsXyzSummonable(nil,mg,ct,ct)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetTargetCards(e):Filter(Card.IsCanBeSpecialSummoned,nil,e,0,tp,false,false)
	if #sg>=2 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if #sg>ft then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		sg=sg:Select(tp,ft,ft,nil)
	end
	local ct=Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	local xyzg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,sg,ct)
	if ct>=2 and #xyzg>0 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local xyzc=xyzg:Select(tp,1,1,nil):GetFirst()
		Duel.XyzSummon(tp,xyzc,nil,sg)
	end
end