--煌星帝エストローム
--Estrome the Mega Monarch
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Summon with 1 tribute
	local e1=aux.AddNormalSummonProcedure(c,true,true,1,1,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0),s.otfilter)
	--Destroy 1 card on the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.otfilter(c)
	return c:IsLevelAbove(5) and c:IsDefense(1000) and c:IsFaceup()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_TRIBUTE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_ONFIELD,nil,tp)
	if chk==0 then return #dg>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,PLAYER_ALL,LOCATION_ONFIELD)
end
function s.filter(c,tp)
	return not c:IsMaximumModeSide() and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
function s.filter2(c)
	return not c:IsMaximumModeSide()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local dg=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_ONFIELD,nil,tp)
	if #dg==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
	local sg=dg:Select(1-tp,1,1,nil)
	Duel.HintSelection(sg,true)
	local dg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,sg)
	if #dg2==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local sg2=dg2:Select(tp,1,1,nil)
	sg2=sg2:AddMaximumCheck()
	Duel.HintSelection(sg2,true)
	Duel.Destroy(sg2,REASON_EFFECT)
end