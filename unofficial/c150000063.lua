--ヒートアップ・サウンド
--Sound Rebound
local s,id=GetID()
function s.initial_effect(c)
	--negation
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--negate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	--e1:SetRange(LOCATION_SZONE)
	if Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 then
		e1:SetCondition(s.negcon1)
	else
		e1:SetCondition(s.negcon2)
	end
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
function s.negcon1(e,tp,eg,ep,ev,re,r,rp)
	s.negcon(e,tp,eg,ep,ev,re,r,rp,CATEGORY_DESTROY)
end
function s.negcon2(e,tp,eg,ep,ev,re,r,rp)
	s.negcon(e,tp,eg,ep,ev,re,r,rp,CATEGORY_NEGATE)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp,cat)
	if not Duel.IsChainNegatable(ev) then return false end
	local ex,tg,tc=Duel.GetOperationInfo(ev,cat)
	return ex and tg~=nil and tc+tg:FilterCount(Card.IsType,nil,TYPE_SPELL)-#tg>0
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
