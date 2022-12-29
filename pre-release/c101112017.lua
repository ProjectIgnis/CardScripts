-- ネムレリアの夢守り－クエット
-- Nemurelia's Dream Defender - Couette
-- Scripted by Satella
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon itself from the hand
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- Negate the activation of your opponent's effect that targets your "Nemurelia" card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.negcon)
	e2:SetCost(s.negcost)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_NEMURELIA}
s.listed_names={CARD_DREAMING_NEMURELIA}
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType,TYPE_PENDULUM),tp,LOCATION_EXTRA,0,1,nil)
end
function s.confilter(c,tp)
	return c:IsSetCard(SET_NEMURELIA) and c:IsFaceup() and c:IsControler(tp) and c:IsOnField()
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_DREAMING_NEMURELIA),tp,LOCATION_EXTRA,0,1,nil) then return false end
	if not (rp==1-tp and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g:IsExists(s.confilter,1,nil,tp)
end
function s.cfilter(c)
	return c:IsFacedown() and c:IsAbleToRemoveAsCost(POS_FACEDOWN)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsRelateToEffect(re) then
		Duel.SendtoGrave(eg,REASON_EFFECT)
	end
end