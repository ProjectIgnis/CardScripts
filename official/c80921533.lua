--死皇帝の陵墓
--Mausoleum of the Emperor
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Activate 1 of these effects
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTarget(s.sumefftg)
	e2:SetOperation(s.sumeffop)
	c:RegisterEffect(e2)
	--Hardcode
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(80921533)
	e3:SetValue(SUMMON_TYPE_NORMAL)
	c:RegisterEffect(e3)
	e2:SetLabelObject(e3)
end
function s.sumfilter(c,se,ct)
	if not (c:IsSummonableCard() and c:CanSummonOrSet(false,se)) then return false end
	local mi,ma=c:GetTributeRequirement()
	return mi==ct or ma==ct
end
function s.sumefftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local se=e:GetLabelObject()
	local b1=Duel.CheckLPCost(tp,1000) and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND,0,1,nil,se,1)
	local b2=Duel.CheckLPCost(tp,2000) and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND,0,1,nil,se,2)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and (b1 or b2) end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	Duel.PayLPCost(tp,op*1000)
	e:SetLabel(op)
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.sumeffop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local se=e:GetLabelObject()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND,0,1,1,nil,se,op):GetFirst()
	if sc then
		Duel.SummonOrSet(tp,sc,false,se)
	end
end