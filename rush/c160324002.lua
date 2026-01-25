--幻竜帝リンドルム
--Lindorm the Mega Monarch
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Summon with 1 tribute
	local e0=aux.AddNormalSummonProcedure(c,true,true,1,1,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0),s.otfilter)
	--Shuffle 1 opponent's card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TODECK)
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
	return c:IsStatus(STATUS_SUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_TRIBUTE) and Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0)==0
end
function s.filter(c)
	return c:IsNotMaximumModeSide()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #dg>1 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local dg=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_ONFIELD,nil,tp)
	if #dg<2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
	local sg=dg:Select(1-tp,2,2,nil)
	Duel.HintSelection(sg)
	local sg2=sg:Select(tp,1,1,nil)
	sg2=sg2:AddMaximumCheck()
	Duel.HintSelection(sg2)
	Duel.SendtoDeck(sg2,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end