--Disgraceful Charity
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		s[0]=false
		s[1]=false
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DISCARD)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		aux.AddValuesReset(function()
			s[0]=false
			s[1]=false
		end)
	end)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local re=tc:GetReasonEffect()
	if re==nil then return end
	while tc do
		if tc:IsLocation(LOCATION_GRAVE) and tc:IsReason(REASON_DISCARD) and re:IsActiveType(TYPE_SPELL) then
			s[tc:GetControler()]=true
		end
		tc=eg:GetNext()
	end
end
function s.filter(c,id,e,tp)
	local re=c:GetReasonEffect()
	return c:IsReason(REASON_DISCARD) and c:GetTurnID()==id and c:IsAbleToHand() and re:IsActiveType(TYPE_SPELL)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return s[tp] and Duel.GetFlagEffect(tp,id)==0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,Duel.GetTurnCount(),e,tp) 
		and Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_GRAVE,1,nil,Duel.GetTurnCount(),e,tp) 
		or Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,Duel.GetTurnCount(),e,tp)
		or Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_GRAVE,1,nil,Duel.GetTurnCount(),e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,LOCATION_GRAVE)
	Duel.RegisterFlagEffect(tp,id,0,0,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,999999,nil,Duel.GetTurnCount(),e,tp)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOHAND)
	local g2=Duel.SelectMatchingCard(1-tp,s.filter,1-tp,LOCATION_GRAVE,0,1,999999,nil,Duel.GetTurnCount(),e,1-tp)
	if #g2>0 then
		Duel.SendtoHand(g2,nil,REASON_EFFECT)
	end
end
