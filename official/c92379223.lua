--黄金の征服王
--El Dorado Adelantado
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.con)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--Halve LP
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_RECOVER)
	e2:SetTarget(s.lptg)
	e2:SetOperation(s.lpop)
	c:RegisterEffect(e2)
end
s.listed_series={0x142}
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsSetCard,0x142),tp,LOCATION_MZONE,0,1,nil)
end
function s.tdfilter(c,set)
	return c:IsFaceup() and c:IsSetCard(set) and c:IsAbleToDeck()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_REMOVED,0,nil,0x143)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,3,3,aux.dncheck,0) and
		Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,0,LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,#dg,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_REMOVED,0,nil,0x143)
	local sg=aux.SelectUnselectGroup(g,e,tp,3,3,aux.dncheck,1,tp,HINTMSG_TODECK)
	if #sg==3 and Duel.SendtoDeck(sg,tp,2,REASON_EFFECT)>0 then
		local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
function s.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_REMOVED,0,nil,0x144)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,3,3,aux.dncheck,0) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,0,LOCATION_REMOVED)
	local rec=math.ceil(Duel.GetLP(1-tp)/2)
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(rec)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_REMOVED,0,nil,0x144)
	local sg=aux.SelectUnselectGroup(g,e,tp,3,3,aux.dncheck,1,tp,HINTMSG_TODECK)
	if #sg==3 and Duel.SendtoDeck(sg,tp,2,REASON_EFFECT)>0 then
		local initial=Duel.GetLP(1-tp)
		local lp=math.ceil(initial/2)
		Duel.SetLP(1-tp,lp)
		local rec=Duel.GetLP(1-tp)
		if rec~=initial then
			Duel.BreakEffect()
			Duel.Recover(tp,rec,REASON_EFFECT)
		end
	end
end
