--ダウン・フォース
--Down Force
local s,id=GetID()
function s.initial_effect(c)
	--Negate and Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c,tp)
	return c:IsOnField() and c:IsMonster() and c:IsControler(tp)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if tp==ep or not Duel.IsChainNegatable(ev) then return false end
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	if ex and tg~=nil and tc+tg:FilterCount(s.cfilter,nil,tp)-#tg>0 then
		return true
	end
	ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_TOHAND)
	if ex and tg~=nil and tc+tg:FilterCount(s.cfilter,nil,tp)-#tg>0 then
		return true
	end
	ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_REMOVE)
	if ex and tg~=nil and tc+tg:FilterCount(s.cfilter,nil,tp)-#tg>0 then
		return true
	end
	ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_TODECK)
	if ex and tg~=nil and tc+tg:FilterCount(s.cfilter,nil,tp)-#tg>0 then
		return true
	end
	ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_RELEASE)
	if ex and tg~=nil and tc+tg:FilterCount(s.cfilter,nil,tp)-#tg>0 then
		return true
	end
	ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_TOGRAVE)
	if ex and tg~=nil and tc+tg:FilterCount(s.cfilter,nil,tp)-#tg>0 then
		return true
	end
	return false
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
	local e8=Effect.CreateEffect(e:GetHandler())
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetCode(EFFECT_DISABLE)
	e8:SetReset(RESET_EVENT|RESETS_STANDARD)
	re:GetHandler():RegisterEffect(e8,true)
	local e9=Effect.CreateEffect(e:GetHandler())
	e9:SetType(EFFECT_TYPE_SINGLE)
	e9:SetCode(EFFECT_DISABLE_EFFECT)
	e9:SetReset(RESET_EVENT|RESETS_STANDARD)
	re:GetHandler():RegisterEffect(e9,true)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end