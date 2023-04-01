--黄金の征服王
--El Dorado Adelantado
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--Destroy cards or halve LP
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
end
s.listed_series={SET_ELDLICH,SET_ELDLIXIR,SET_GOLDEN_LAND}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_ELDLICH),tp,LOCATION_MZONE,0,1,nil)
end
function s.tdfilter(c)
	return c:IsFaceup() and c:IsSpellTrap() and c:IsAbleToDeck()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g1=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_REMOVED,0,nil):Filter(Card.IsSetCard,nil,SET_ELDLIXIR)
	local g2=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_REMOVED,0,nil):Filter(Card.IsSetCard,nil,SET_GOLDEN_LAND)
	local b1=#g1>=3 and aux.SelectUnselectGroup(g1,e,tp,3,3,aux.dncheck,0)
		and Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
	local b2=#g2>=3 and aux.SelectUnselectGroup(g2,e,tp,3,3,aux.dncheck,0)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)})
	if op==1 then
		e:SetCategory(CATEGORY_TODECK+CATEGORY_DESTROY)
		e:SetOperation(s.desop)
		local dg=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,#dg,0,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_TODECK+CATEGORY_RECOVER)
		e:SetOperation(s.lpop)
		local rec=math.ceil(Duel.GetLP(1-tp)/2)
		Duel.SetTargetPlayer(tp)
		Duel.SetTargetParam(rec)
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,0,LOCATION_REMOVED)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_REMOVED,0,nil):Filter(Card.IsSetCard,nil,SET_ELDLIXIR)
	if #g<3 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,3,3,aux.dncheck,1,tp,HINTMSG_TODECK)
	if #sg==3 and Duel.SendtoDeck(sg,tp,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		local dg=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_REMOVED,0,nil):Filter(Card.IsSetCard,nil,SET_GOLDEN_LAND)
	if #g<3 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,3,3,aux.dncheck,1,tp,HINTMSG_TODECK)
	if #sg==3 and Duel.SendtoDeck(sg,tp,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
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