--ギアギアチェンジ
--Geargia Change
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
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
function s.filter(c,e,tp)
	return c:IsSetCard(SET_GEARGIANO) and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.xyzfilter(c,mg,ct)
	return c:IsXyzSummonable(nil,mg,2,ct)
end
function s.rescon(exg)
	return function(sg)
		if #sg<2 then return false end
		if not sg:CheckDifferentProperty(Card.GetCode) then return false,false end
		return exg:IsExists(Card.IsXyzSummonable,1,nil,nil,sg,#sg,#sg)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local mg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil,e,tp)
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local exg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,mg,ct)
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and ct>1 and aux.SelectUnselectGroup(mg,e,tp,2,math.min(#mg,ct),s.rescon(exg),0) end
	local sg=aux.SelectUnselectGroup(mg,e,tp,2,math.min(#mg,ct),s.rescon(exg),1,tp,HINTMSG_SPSUMMON,s.rescon(exg))
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,#sg,0,0)
end
function s.filter2(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	local g=Duel.GetTargetCards(e):Match(s.filter2,nil,e,tp)
	local ct=Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	local xyzg=Duel.GetMatchingGroup(Card.IsXyzSummonable,tp,LOCATION_EXTRA,0,nil,nil,g,ct,ct)
	if ct>=2 and #xyzg>0 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		Duel.XyzSummon(tp,xyz,g,nil,#g,#g)
	end
end
