--転倒無視
--Ignoring Insect
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT) and c:IsAttackPos() and c:IsCanChangePositionRush()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil) end
end
function s.posfilter(c)
	return c:IsAttackPos() and c:IsCanChangePositionRush()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,3,nil)
	if #g==0 then return end
	Duel.HintSelection(g,true)
	if Duel.ChangePosition(g,POS_FACEUP_DEFENSE)~=#g then return end
	if not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsDefensePos),tp,LOCATION_MZONE,0,2,nil) then return end
	local dg=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
	if #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
		local sg=dg:Select(tp,1,1,nil)
		if #sg==0 then return end
		Duel.BreakEffect()
		Duel.ChangePosition(sg,POS_FACEUP_DEFENSE)
	end
end