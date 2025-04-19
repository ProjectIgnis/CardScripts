--ヴォイドヴェルグ・ゴッドレクイエム
--Voidvelg God Requiem
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	c:RegisterFlagEffect(FLAG_TRIPLE_TRIBUTE,0,0,1)
	--Summon with 3 tribute
	local e1=aux.AddNormalSummonProcedure(c,true,true,3,3,SUMMON_TYPE_TRIBUTE+1,aux.Stringid(id,0))
	--Destroy all monsters your opponent controls
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.condition)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SUMMON_TURN) and c:GetSummonType()==SUMMON_TYPE_TRIBUTE+1
end
function s.tdfilter(c)
	return c:IsMonster() and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,5,nil) end
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsNotMaximumModeSide()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsNotMaximumModeSide,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,5,5,nil)
	Duel.HintSelection(g,true)
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)<1 then return end
	--Effect
	local g1=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
	local sg=g1:GetMaxGroup(Card.GetLevel)
	if Duel.Destroy(sg,REASON_EFFECT)>0 then
		local g2=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
		local atk=g2:GetSum(Card.GetAttack)
		if #g2>0 and atk>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Damage(1-tp,atk,REASON_EFFECT)
		end
	end
end