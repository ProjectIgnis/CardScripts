--原始生命態ニビル
--Nibiru, the Primal Being
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMING_MAIN_END+TIMING_SUMMON+TIMING_SPSUMMON)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--count
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SUMMON_SUCCESS)
		Duel.RegisterEffect(ge2,0)
	end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	for tc in aux.Next(eg) do
		Duel.RegisterFlagEffect(tc:GetSummonPlayer(),id,RESET_PHASE+PHASE_END,0,1)
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(1-tp,id)>=5 and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then
		return #g>0 and Duel.GetMZoneCount(tp,g,tp)>0 and Duel.GetMZoneCount(1-tp,g,tp)>0
			and Duel.IsPlayerCanSpecialSummonCount(tp,2)
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,g:GetSum(Card.GetBaseAttack),g:GetSum(Card.GetBaseDefense),11,RACE_ROCK,ATTRIBUTE_LIGHT,POS_FACEUP,1-tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
end
function s.operationvalueatk(c)
	return math.max(c:GetBaseAttack(),0)
end
function s.operationvaluedef(c)
	return math.max(c:GetBaseDefense(),0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsReleasable),tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if Duel.Release(g,REASON_EFFECT)==0 then return end
	if not c:IsRelateToEffect(e) then return end
	local og=Duel.GetOperatedGroup()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
		and Duel.GetMZoneCount(1-tp,nil,tp)>0 then
		local atk=og:GetSum(s.operationvalueatk)
			local def=og:GetSum(s.operationvaluedef)
		if not Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,atk,def,11,RACE_ROCK,ATTRIBUTE_LIGHT,POS_FACEUP,1-tp) then return end
		Duel.BreakEffect()
		local token=Duel.CreateToken(tp,id+1)
		Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE)
		e2:SetValue(def)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e2)
		Duel.SpecialSummonComplete()
	end
end
