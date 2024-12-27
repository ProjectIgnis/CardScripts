--威迫鉱石－サモナイト
--Intimidating Ore - Summonite
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon monster(s)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E|TIMING_MAIN_END)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
function s.sptgfilter(c,e)
	return c:IsMonster() and c:IsCanBeEffectTarget(e)
end
function s.sprescon(g,e,tp)
	return g:IsExists(Card.IsCanBeSpecialSummoned,1,nil,e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.sptgfilter,tp,LOCATION_GRAVE,0,nil,e)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and aux.SelectUnselectGroup(g,e,tp,3,3,s.sprescon,0) end
	local g=aux.SelectUnselectGroup(g,e,tp,3,3,s.sprescon,1,tp,HINTMSG_SPSUMMON)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft==0 then return end
	local g=Duel.GetTargetCards(e)
	if #g==0 or not s.sprescon(g,e,tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if not tc then return end
	Duel.HintSelection(tc,true)
	g:RemoveCard(tc)
	local b1=tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
	local b2=#g:Match(Card.IsCanBeSpecialSummoned,nil,e,0,tp,false,false)>0
	local op=Duel.SelectEffect(1-tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	if op==1 then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	elseif op==2 then
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
		if ft<#g then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			g=g:Select(tp,ft,ft,nil)
		end
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end