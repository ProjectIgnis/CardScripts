--見下した条約
--Despised Reality
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCondition(function(e,tp) return Duel.IsTurnPlayer(1-tp) end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,1000)
end
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p=1-tp
	if Duel.GetLocationCount(p,LOCATION_MZONE,p)>0
		and Duel.IsExistingMatchingCard(s.spfilter,p,LOCATION_DECK,0,1,nil,e,p)
		and Duel.IsPlayerCanDraw(tp,2)
		and Duel.SelectYesNo(p,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(p,s.spfilter,p,LOCATION_DECK,0,1,1,nil,e,p)
		if #g>0 and Duel.SpecialSummon(g,0,p,p,false,false,POS_FACEUP)>0 then
			Duel.Draw(tp,2,REASON_EFFECT)
		end
	else
		Duel.Damage(tp,1000,REASON_EFFECT)
	end
end