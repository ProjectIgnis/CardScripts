--Counterbalance
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--discard opp deck
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_REPEAT)
	e2:SetCountLimit(1)
	e2:SetCondition(s.discon)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	--discard your deck
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCategory(CATEGORY_DECKDES)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_REPEAT)
	e3:SetCountLimit(1)
	e3:SetCondition(s.discon2)
	e3:SetTarget(s.target2)
	e3:SetOperation(s.activate2)
	e3:SetLabelObject(e1)
	c:RegisterEffect(e3)	
end

function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,TYPE_MONSTER) end
	Duel.SetTargetPlayer(1-tp)
	local dam=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_MZONE,LOCATION_MZONE,nil,TYPE_MONSTER)*1
	Duel.SetTargetParam(dam)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local dam=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_MZONE,LOCATION_MZONE,nil,TYPE_MONSTER)*1
	Duel.DiscardDeck(1-tp,dam,REASON_EFFECT)
end

function s.discon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end

function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,TYPE_MONSTER) end
	Duel.SetTargetPlayer(tp)
	local dis=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_MZONE,LOCATION_MZONE,nil,TYPE_MONSTER)*1
	Duel.SetTargetParam(dis)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,dis)
end
function s.activate2(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local dis=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_MZONE,LOCATION_MZONE,nil,TYPE_MONSTER)*1
	Duel.DiscardDeck(tp,dis,REASON_EFFECT)
end
