--天使のお注射
--Fairy's Injection
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Activate(summon)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_DRAW)
	e2:SetCondition(s.condition2)
	c:RegisterEffect(e2)
end
function s.filter1(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsLocation(LOCATION_MZONE)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter1,1,nil,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_MZONE)
end
function s.cfilter(c)
	return c:IsMonster() and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAttack(400) and c:IsDefense(1500)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.HintSelection(g,true)
	if Duel.SendtoGrave(g,REASON_EFFECT)==0 then return end
	if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsNotMaximumModeSide,tp,0,LOCATION_MZONE,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,Card.IsNotMaximumModeSide,tp,0,LOCATION_MZONE,1,1,nil)
		dg=dg:AddMaximumCheck()
		Duel.HintSelection(dg)
		Duel.BreakEffect()
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and Duel.IsTurnPlayer(1-tp)
end