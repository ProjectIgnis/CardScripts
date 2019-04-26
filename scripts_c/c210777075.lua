---Nidhogg The Nordic Dragon
--designed by Thaumablazer#4134, scripted by Naim
function c210777075.initial_effect(c)
	aux.AddXyzProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x4b),10,3,nil,nil,12)
	c:EnableReviveLimit()
	--spsummon limit
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.xyzlimit)
	c:RegisterEffect(e1)
	--immune effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c210777075.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--immune tribute (opponente)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UNRELEASABLE_SUM)
	e3:SetCondition(c210777075.indcon)
	e3:SetValue(c210777075.sumlimit)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_RELEASE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c210777075.indcon)
	e4:SetTargetRange(0,1)
	e4:SetTarget(c210777075.relval)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	--attack all
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_ATTACK_ALL)
	e5:SetCondition(c210777075.allcon)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	--pierce
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e6)
	--negate activation
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(210777075,0))
	e7:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e7:SetType(EFFECT_TYPE_QUICK_O)
	e7:SetCode(EVENT_CHAINING)
	e7:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCountLimit(1,210777075)
	e7:SetCondition(c210777075.negcon)
	e7:SetCost(c210777075.cost)
	e7:SetTarget(c210777075.negtg)
	e7:SetOperation(c210777075.negop)
	c:RegisterEffect(e7)
	--disable spsummon
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(210777075,0))
	e8:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e8:SetType(EFFECT_TYPE_QUICK_O)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCode(EVENT_SUMMON)
	e8:SetCountLimit(1,210777075)
	e8:SetCondition(c210777075.discon)
	e8:SetCost(c210777075.cost)
	e8:SetTarget(c210777075.distg)
	e8:SetOperation(c210777075.disop)
	c:RegisterEffect(e8)
	local e9=e8:Clone()
	e9:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e9)
	local e10=e8:Clone()
	e10:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e10)
end
function c210777075.filter(c)
	return c:IsFaceup() and c:IsCode(210777081)
end
function c210777075.indcon(e)
	return Duel.IsExistingMatchingCard(c210777075.filter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
function c210777075.sumlimit(e,c)
	if not c then return false end
	return not c:IsControler(e:GetHandlerPlayer())
end
function c210777075.relval(e,c)
	return c==e:GetHandler()
end
function c210777075.allcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayCount()>0
end
function c210777075.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if ep==tp or c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
function c210777075.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function c210777075.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function c210777075.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
function c210777075.filter(c,tp)
	return c:GetSummonPlayer()==tp
end
function c210777075.discon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and eg:IsExists(c210777075.filter,1,nil,1-tp)
end
function c210777075.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(c210777075.filter,nil,1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,g,g:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function c210777075.disop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c210777075.filter,nil,1-tp)
	Duel.NegateSummon(g)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end