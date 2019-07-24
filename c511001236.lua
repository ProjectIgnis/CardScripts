--モンスターレジスター
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_DRAW_PHASE)
	e1:SetCost(s.cost)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function s.cfilter(c)
	return c:GetLevel()>0
end
function s.filter(c,tp)
	return c:GetLevel()>0 and c:IsControler(tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.cfilter,1,nil) end
	local g1=eg:Filter(s.filter,nil,tp)
	local g2=eg:Filter(s.filter,nil,1-tp)
	if #g1>0 then
		Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
	end
	if #g2>0 then
		Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,1)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g1=eg:Filter(s.filter,nil,tp)
	local g2=eg:Filter(s.filter,nil,1-tp)
	local lv1=g1:GetSum(Card.GetLevel)
	local lv2=g2:GetSum(Card.GetLevel)
	if #g1>0 and lv1>0  then
		Duel.DiscardDeck(tp,lv1,REASON_EFFECT)
	end
	if #g2>0 and lv2>0  then
		Duel.DiscardDeck(1-tp,lv2,REASON_EFFECT)
	end
end
