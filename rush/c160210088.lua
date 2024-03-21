--キングス・オーソリティ
--King's Authority
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Prevents the activation of the effects of your opponent's monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
function s.filter1(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsLocation(LOCATION_MZONE)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter1,1,nil,tp) and Duel.IsTurnPlayer(1-tp)
end
function s.tgfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(5) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FIEND)
end
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsLevelAbove(4)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(aux.FilterMaximumSideFunctionEx(s.tgfilter),tp,LOCATION_MZONE,0,nil)
	if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil,e,tp) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local ct=Duel.GetMatchingGroupCount(aux.FilterMaximumSideFunctionEx(s.tgfilter),tp,LOCATION_MZONE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_MZONE,1,ct,nil)
	Duel.HintSelection(g,true)
	local c=e:GetHandler()
	for tc in g:Iter() do
		--Cannot activate its effects
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3302)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
		--Cannot be Tributed
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UNRELEASABLE_SUM)
		e2:SetReset(RESETS_STANDARD_PHASE_END|PHASE_END)
		e2:SetValue(1)
		tc:RegisterEffect(e2,true)
	end
end