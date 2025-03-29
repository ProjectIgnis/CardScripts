--ЯＲＵＭ－レイド・ラプターズ・フォース
--Rise Rank-Up-Magic Raidraptor's Force
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(function(e,tp) return Duel.IsMainPhase() or (Duel.IsTurnPlayer(1-tp) and Duel.IsBattlePhase()) end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_RAIDRAPTOR}
function s.tgfilter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(SET_RAIDRAPTOR) and c:IsFaceup()
		and c:IsCanBeXyzMaterial(nil,tp,REASON_EFFECT) and c:IsCanBeEffectTarget(e)
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,sg:GetSum(Card.GetRank))
end
function s.spfilter(c,e,tp,rk)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(SET_RAIDRAPTOR) and c:IsRank(rk) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and (not c.rum_limit or g:IsExists(function(mc) return c.rum_limit(mc,e) end,1,nil))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then return #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,#g,s.rescon,0) end
	local tg=aux.SelectUnselectGroup(g,e,tp,2,#g,s.rescon,1,tp,HINTMSG_XMATERIAL,s.rescon)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	local gyg=tg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #gyg>0 then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,gyg,#gyg,tp,0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	local futg=tg:Filter(Card.IsFaceup,nil)
	if #futg<2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,futg:GetSum(Card.GetRank)):GetFirst()
	if sc and Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
		sc:CompleteProcedure()
		tg=tg:Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
		if #tg==0 then return end
		Duel.Overlay(sc,tg)
	end
end