--魔鍵錠－施－
--Magikey Locking
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_MAGIKEY}
function s.costfilter(c)
	return not c:IsType(TYPE_TOKEN) and (c:IsType(TYPE_NORMAL) or c:IsSetCard(SET_MAGIKEY))
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.costfilter,1,false,aux.ReleaseCheckMMZ,nil) end
	local g=Duel.SelectReleaseGroupCost(tp,s.costfilter,1,1,false,aux.ReleaseCheckMMZ,nil)
	Duel.Release(g,REASON_COST)
end
function s.filter(c,e,tp)
	return c:IsMonster() and c:HasLevel() and (c:IsType(TYPE_NORMAL) or c:IsSetCard(SET_MAGIKEY))
		and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.rescon(sg,e,tp,mg)
	return sg:GetSum(Card.GetLevel)<=8
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local tg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then return aux.SelectUnselectGroup(tg,e,tp,1,1,s.rescon,0) end
	local ft=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),2)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or not aux.SelectUnselectGroup(tg,e,tp,2,2,s.rescon,0) then
		ft=1
	end
	local g=aux.SelectUnselectGroup(tg,e,tp,1,ft,s.rescon,1,tp,HINTMSG_SPSUMMON)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,0,0)
end
function s.exfilter(c,sfunc)
	return c:IsSetCard(SET_MAGIKEY) and sfunc(c)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g<=0 or Duel.GetLocationCount(tp,LOCATION_MZONE)<#g or (#g>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) then return end
	if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)==#g then
		local sg=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_EXTRA,0,nil,Card.IsSynchroSummonable)
		local xg=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_EXTRA,0,nil,Card.IsXyzSummonable)
		local opt1,opt2=#sg>0,#xg>0
		if (opt1 or opt2) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			local opt
			if opt1 and opt2 then
				opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
			elseif opt1 and not opt2 then
				opt=Duel.SelectOption(tp,aux.Stringid(id,2))
			elseif opt2 and not opt1 then
				opt=Duel.SelectOption(tp,aux.Stringid(id,3))+1
			end
			if opt==0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local sc=sg:Select(tp,1,1,nil):GetFirst()
				Duel.SynchroSummon(tp,sc)
			elseif opt==1 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local xc=xg:Select(tp,1,1,nil):GetFirst()
				Duel.XyzSummon(tp,xc)
			end
		end
	end
end