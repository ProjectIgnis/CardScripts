--破壊竜ガンドラ－ギガ・レイズ
--Gandora Giga Rays the Dragon of Destruction
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--special summon rule
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--atk gain
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.value)
	c:RegisterEffect(e2)
	--variable effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(s.cost)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
s.listed_series={0xf5}
function s.cfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,c)
	return #g>=2 and Duel.GetLocationCount(tp,LOCATION_MZONE)>-2 and aux.SelectUnselectGroup(g,e,tp,2,2,aux.ChkfMMZ(1),0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,c)
	local g=aux.SelectUnselectGroup(g,e,tp,2,2,aux.ChkfMMZ(1),1,tp,HINTMSG_TOGRAVE)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoGrave(g,REASON_COST)
	g:DeleteGroup()
end
function s.value(e,c)
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_REMOVED,LOCATION_REMOVED)*300
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
function s.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xf5)
end
function s.rmfilter(c)
	return c:IsAbleToRemove() and (c:IsLocation(LOCATION_SZONE) or aux.SpElimFilter(c,false,true))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local gc=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil):GetClassCount(Card.GetCode)
	if chk==0 then
		local b1=Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
		local b2=Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
		local b3=Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,c)
		return (gc==1 and b1) or (gc==2 and b2) or (gc>2 and b3)
	end
	if gc==1 then
		e:SetCategory(CATEGORY_DESTROY)
		local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	else
		e:SetCategory(CATEGORY_REMOVE)
		local loc=LOCATION_ONFIELD
		if gc>2 then loc=LOCATION_ONFIELD+LOCATION_GRAVE end
		local g=Duel.GetMatchingGroup(s.rmfilter,tp,loc,loc,c)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local gc=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil):GetClassCount(Card.GetCode)
	if gc==1 then
		local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
		Duel.Destroy(g,REASON_EFFECT)
	else
		local loc=LOCATION_ONFIELD
		if gc>2 then loc=LOCATION_ONFIELD+LOCATION_GRAVE end
		local g=Duel.GetMatchingGroup(s.rmfilter,tp,loc,loc,c)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
