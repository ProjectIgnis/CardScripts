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
s.listed_series={0x1072}
function s.filter(c,e,tp)
	return c:IsSetCard(0x1072) and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.xyzfilter(c,mg,ct)
	return c:IsXyzSummonable(nil,mg,2,ct)
end
function s.mfilter1(c,mg,exg,ct)
	return mg:IsExists(s.mfilter2,1,nil,Group.FromCards(c),mg,exg,ct)
end
function s.mfilter2(c,g,mg,exg,ct)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		if c:IsCode(tc:GetCode()) then return false end
	end
	g:AddCard(c)
	local result=exg:IsExists(Card.IsXyzSummonable,1,nil,nil,g,#g,#g)
		or (#g<ct and mg:IsExists(s.mfilter2,1,nil,g,mg,exg,ct))
	g:RemoveCard(c)
	return result
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local mg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil,e,tp)
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local exg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,mg,ct)
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and ct>1 and mg:IsExists(s.mfilter1,1,nil,mg,exg,ct) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg1=mg:FilterSelect(tp,s.mfilter1,1,1,nil,mg,exg,ct)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg2=mg:FilterSelect(tp,s.mfilter2,1,1,nil,sg1,mg,exg,ct)
	sg1:Merge(sg2)
	while #sg1<ct and mg:IsExists(s.mfilter2,1,nil,sg1,mg,exg,ct)
		and (not exg:IsExists(Card.IsXyzSummonable,1,nil,nil,sg1,#sg1,#sg1) or Duel.SelectYesNo(tp,aux.Stringid(id,0))) do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg3=mg:FilterSelect(tp,s.mfilter2,1,1,nil,sg1,mg,exg,ct)
		sg1:Merge(sg3)
	end
	Duel.SetTargetCard(sg1)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg1,#sg1,0,0)
end
function s.filter2(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spfilter(c,mg,ct)
	return c:IsXyzSummonable(nil,mg,ct,ct)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(s.filter2,nil,e,tp)
	local ct=Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	local xyzg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,g,ct)
	if ct>=2 and #xyzg>0 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		Duel.XyzSummon(tp,xyz,nil,g)
	end
end
