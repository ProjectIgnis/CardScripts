--魔法名－「解体し統合せよ」
--Alpha Summon
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E|TIMING_MAIN_END)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
function s.spfilter(c,e,tp,targ_p)
	return c:IsFaceup() and c:IsMonster() and c:IsCanBeEffectTarget(e)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,targ_p)
end
function s.sprescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetControler)==2
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g0=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_REMOVED,0,nil,e,tp,1-tp)
	local g1=Duel.GetMatchingGroup(s.spfilter,tp,0,LOCATION_REMOVED,nil,e,tp,tp)
	if chk==0 then return #g0>0 and #g1>0
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0 end
	local tg=aux.SelectUnselectGroup(g0+g1,e,tp,2,2,s.sprescon,1,tp,HINTMSG_SPSUMMON)
	e:SetLabelObject((g0&tg):GetFirst())
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,2,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		or Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)==0 then return end
	local g=Duel.GetTargetCards(e)
	if #g==0 then return end
	local c0=e:GetLabelObject()
	if g:IsContains(c0) and c0:IsControler(tp)
		and Duel.SpecialSummonStep(c0,0,tp,1-tp,false,false,POS_FACEUP)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		local c1=g:RemoveCard(c0):GetFirst()
		if c1 and c1:IsControler(1-tp) then
			Duel.SpecialSummonStep(c1,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	Duel.SpecialSummonComplete()
end