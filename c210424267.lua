--Moon Burst's Reaction
local card = c210424267
function card.initial_effect(c)
	--indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--indestructable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x666))
	e2:SetValue(card.efilter)
	c:RegisterEffect(e2)
	--move card to scale
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCondition(card.pencon)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(card.pentg)
	e3:SetOperation(card.penop)
	c:RegisterEffect(e3)
end
function card.efilter(e,te)
	return not te:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
	and te:GetOwnerPlayer()~=e:GetOwnerPlayer()
end
function card.filter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x666) and not c:IsForbidden()
end
function card.pencon(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetTurnCount()~=e:GetHandler():GetTurnID() or e:GetHandler():IsReason(REASON_RETURN) 
	and Duel.IsExistingMatchingCard(card.filter,tp,LOCATION_DECK,0,1,nil)
end
function card.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
function card.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(card.filter,tp,LOCATION_DECK,0,nil)
	local ct=0
	if Duel.CheckLocation(tp,LOCATION_PZONE,0) then ct=ct+1 end
	if Duel.CheckLocation(tp,LOCATION_PZONE,1) then ct=ct+1 end
	if ct>0 and g:GetCount()>0 then
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local sg=g:Select(tp,1,ct,nil)
	local sc=sg:GetFirst()
	while sc do
	Duel.MoveToField(sc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	Duel.MoveToField(sc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	sc=sg:GetNext()
end
end
end