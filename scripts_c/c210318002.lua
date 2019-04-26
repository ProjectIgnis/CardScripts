--U.A.Cheerleader
function c210318002.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,210318002)
	e1:SetCondition(c210318002.spcon)
	e1:SetOperation(c210318002.spop)
	c:RegisterEffect(e1)
	--ATK
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(210318002,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_DAMAGE_STEP)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,210318002)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCost(c210318002.atkcost)
	e2:SetTarget(c210318002.atktg)
	e2:SetOperation(c210318002.atkop)
	c:RegisterEffect(e2)
	end
	
function c210318002.spfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb2) and not c:IsCode(210318002) and c:IsAbleToHandAsCost()
end
function c210318002.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>-1
		and Duel.IsExistingMatchingCard(c210318002.spfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
function c210318002.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,c210318002.spfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SendtoHand(g,nil,REASON_COST)
end
function c210318002.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	e:SetLabel(e:GetHandler():GetAttack())
	Duel.Release(e:GetHandler(),REASON_COST)
end
function c210318002.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xb2)
end
function c210318002.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210318002.filter,tp,LOCATION_MZONE,0,1,nil) end
end
function c210318002.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c210318002.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetOwnerPlayer(tp)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabel())
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end