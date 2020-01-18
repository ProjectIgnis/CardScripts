--デュアル・アブレーション
--Gemini Ablation
--Logical Nonsense

--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetTarget(s.tg)
	c:RegisterEffect(e1)
	--2 in 1
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	c:RegisterEffect(e2)
end
	--Use effect at the same time it was flipped
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if s.condition(e,tp,eg,ep,ev,re,r,rp,0) and s.target(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,94) then
		s.target(e,tp,eg,ep,ev,re,r,rp,1)
	end
end
	--Check if it's the Main Phase
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
	--What makes it HOPT
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
	--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=s.discost(e,tp,eg,ep,ev,re,r,rp,0) and s.sptg1(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=s.spcost(e,tp,eg,ep,ev,re,r,rp,0) and s.sptg2(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return b1 or b2 end
	local stable={}
	local dtable={}
	if b1 then
		table.insert(stable,1)
		table.insert(dtable,aux.Stringid(id,1))
	end
	if b2 then
		table.insert(stable,2)
		table.insert(dtable,aux.Stringid(id,2))
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
	local op=stable[Duel.SelectOption(tp,table.unpack(dtable))+1]
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetOperation(s.spop1)
		s.discost(e,tp,eg,ep,ev,re,r,rp,1)
		s.sptg1(e,tp,eg,ep,ev,re,r,rp,1)
	elseif op==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RELEASE)
		e:SetOperation(s.spop2)
		s.spcost(e,tp,eg,ep,ev,re,r,rp,1)
		s.sptg2(e,tp,eg,ep,ev,re,r,rp,1)
	end
end
	--Check for gemini monster that be special summoned
function s.filter1(c,e,tp)
	return c:IsType(TYPE_DUAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
	--Check for gemini monster
function s.filter2(c)
	return c:IsFaceup() and c:IsType(TYPE_DUAL) and c:IsReleasableByEffect()
end
	--Check for FIRE warrior monster
function s.filter3(c,e,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
	--Discard cost
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return s.cost(e,tp,eg,ep,ev,re,r,rp,chk) and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_DISCARD+REASON_COST)
	s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
end
function s.costfilter(c,e,tp)
	return c:IsDiscardable() and Duel.IsExistingMatchingCard(s.filter3,tp,LOCATION_HAND+LOCATION_DECK,0,1,c,e,tp)
end
	--"Cost"
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return s.discost(e,tp,eg,ep,ev,re,r,rp,chk) end
	s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
	--Activation legality
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
	--Activation legality
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=0 then
			e:SetLabel(0)
			return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil,e,tp) and Duel.CheckReleaseGroup(tp,s.filter2,1,nil)
		else
			return Duel.IsExistingMatchingCard(s.filter3,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) and Duel.CheckReleaseGroup(tp,s.filter2,1,nil)
		end
	end
	if e:GetLabel()~=0 then
		e:SetLabel(0)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
		local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
	--Special summon 1 gemini monster from deck, gains its effects
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		local tc=g:GetFirst()
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			tc:EnableDualState()
		end
		Duel.SpecialSummonComplete()
	end
end
	--Tribute 1 gemini monster, special summon a FIRE warrior, destroy a card if the tributed was in gemini state
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_MZONE,0,1,1,nil)
	if #g>0 and Duel.Release(g,REASON_EFFECT)>0 then
		local tc=g:GetFirst()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.filter3,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
		if #sg>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			if (tc:GetPreviousTypeOnField()&TYPE_EFFECT>0) then
				local dg1=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
				if #dg1>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
					Duel.BreakEffect()
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
					local dg2=dg1:Select(tp,1,1,nil)
					Duel.HintSelection(dg2)
					Duel.Destroy(dg2,REASON_EFFECT)
				end
			end
		end
	end
end
