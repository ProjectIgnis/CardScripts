--覇者の鳴動
--The Ruler's Rumbling
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Apply these effects, in sequence, based on the number of monsters your opponent Special Summoned this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--Keep track of how many monsters each player has Special Summoned in a given turn
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_names={CARD_RED_DRAGON_ARCHFIEND}
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local g0,g1=eg:Split(Card.IsSummonPlayer,nil,0)
	for sc0 in g0:Iter() do
		Duel.RegisterFlagEffect(0,id,RESET_PHASE|PHASE_END,0,1)
	end
	for sc1 in g1:Iter() do
		Duel.RegisterFlagEffect(1,id,RESET_PHASE|PHASE_END,0,1)
	end
end
function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsSynchroMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsFaceup()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetFlagEffect(1-tp,id)
	if chk==0 then
		local b1=ct>=1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp)
		local b2=ct>=3
		local b3=ct>=5 and Duel.IsExistingMatchingCard(Card.IsCanTurnSet,tp,0,LOCATION_MZONE,1,nil)
		return b1 or b2 or b3
	end
	if ct>=1 then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
	end
	if ct>=5 then
		Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,1-tp,LOCATION_MZONE)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
	Duel.SetPossibleOperationInfo(0,CATEGORY_POSITION,nil,1,1-tp,LOCATION_MZONE)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and ct>=10 then
		Duel.SetChainLimit(aux.FALSE)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetFlagEffect(1-tp,id)
	local breakeff=false
	if ct>=1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
		breakeff=true
	end
	if ct>=3 then
		if breakeff then Duel.BreakEffect() end
		local c=e:GetHandler()
		local reset_count=Duel.IsTurnPlayer(tp) and 2 or 1
		aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,1),RESET_PHASE|PHASE_END|RESET_SELF_TURN,reset_count)
		--"Red Dragon Archfiend" in your Monster Zone is unaffected by your opponent's activated effects until the end of your next turn
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(aux.TargetBoolFunction(Card.IsCode,CARD_RED_DRAGON_ARCHFIEND))
		e1:SetValue(function(e,te) return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActivated() end)
		e1:SetReset(RESET_PHASE|PHASE_END|RESET_SELF_TURN,reset_count)
		Duel.RegisterEffect(e1,tp)
		breakeff=true
	end
	if ct>=5 then
		if breakeff then Duel.BreakEffect() end
		local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,0,LOCATION_MZONE,nil)
		if #g>0 then
			Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
		end
	end
end