--斬機超階乗
--Processlayer Superfactorial
--Old script by AlphaKretin
--Script by edo9300
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.announcecost)
	e1:SetTarget(s.target(s.synfilter,s.srescon))
	e1:SetOperation(s.operation(s.synfilter,function(sc,g,tp) Auxiliary.SynchroSend=5 Duel.SynchroSummon(tp,sc,nil,g,#g,#g) end))
	c:RegisterEffect(e1)
	--xyz summon
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetTarget(s.target(s.xyzfilter,s.xrescon))
	e2:SetOperation(s.operation(s.xyzfilter,function(sc,g,tp) Duel.XyzSummon(tp,sc,g) end))
	c:RegisterEffect(e2)
end
s.listed_series={0x132}
function s.announcecost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.relfilter(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.matfilter(c,e,tp)
	return c:IsSetCard(0x132) and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.synfilter(c,mg)
	return c:IsSetCard(0x132) and c:IsType(TYPE_SYNCHRO) and (not mg or c:IsSynchroSummonable(nil,mg,#mg,#mg))
end
function s.srescon(exg)
	return function(sg,e,tp,mg)
		return aux.dncheck(sg,e,tp,mg) and exg:IsExists(Card.IsSynchroSummonable,1,nil,nil,sg,#sg,#sg)
	end
end
function s.xyzfilter(c,mg)
	return c:IsSetCard(0x132) and c:IsType(TYPE_XYZ) and (not mg or c:IsXyzSummonable(mg,#mg,#mg))
end
function s.xrescon(exg)
	return function(sg,e,tp,mg)
		return aux.dncheck(sg,e,tp,mg) and exg:IsExists(Card.IsXyzSummonable,1,nil,sg,#sg,#sg)
	end
end
function s.target(fil,con)
	return function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		local exg=Duel.GetMatchingGroup(fil,tp,LOCATION_EXTRA,0,nil)
		local cancelcon=con(exg)
		if chkc then return chkc:IsControler(tp) and c:IsLocation(LOCATION_GRAVE) and c:IsSetCard(0x132) and chkc:IsCanBeSpecialSummoned(e,0,tp,false,false) and cancelcon(Group.FromCards(chkc)) end
		local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
		local min=math.min(math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and 1 or 99),1)
		if chk==0 then return min>0 and Duel.IsPlayerCanSpecialSummonCount(tp,2)
			and Duel.GetLocationCountFromEx(tp)>0
			and aux.SelectUnselectGroup(mg,e,tp,1,3,cancelcon,0) end
		local sg=aux.SelectUnselectGroup(mg,e,tp,1,3,cancelcon,chk,tp,HINTMSG_SPSUMMON,cancelcon)
		Duel.SetTargetCard(sg)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,#sg,0,0)
	end
end
function s.operation(fil,fun)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local g=Duel.GetTargetCards(e):Filter(s.relfilter,nil,e,tp)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<#g or #g==0 or (Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and #g>1) then return end
		for tc in aux.Next(g) do
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			tc:RegisterEffect(e2)
		end
		Duel.SpecialSummonComplete()
		if Duel.GetLocationCountFromEx(tp,tp,g)<=0 then return end
		Duel.BreakEffect()
		local syng=Duel.GetMatchingGroup(fil,tp,LOCATION_EXTRA,0,nil,g)
		if #syng>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local c=syng:Select(tp,1,1,nil):GetFirst()
			fun(c,g,tp)
		end
	end
end
