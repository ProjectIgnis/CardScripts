--レザーライフ・ドラゴン
--Insurrection Dragon
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Increase ATK and prevent destruction by Trap effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,4,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=Duel.GetMatchingGroupCountRush(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,ct*700)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,4,4,nil)
	Duel.HintSelection(g,true)
	Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	Duel.SortDeckbottom(tp,tp,#g)
	--Gain 700 ATK per each monster on the field
	local ct=Duel.GetMatchingGroupCountRush(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
	e1:SetValue(ct*700)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END)
	c:RegisterEffect(e1,true)
	--Once this turn, cannot be destroyed by Trap Card effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END)
	e2:SetValue(s.indval)
	c:RegisterEffect(e2,true)
end
function s.indval(e,re,r,rp)
	return (r&REASON_EFFECT)~=0 and re:IsTrapEffect() and re:GetOwnerPlayer()~=e:GetOwnerPlayer()
end
