--Subverted Reirrac
function c210001108.initial_effect(c)
	--norm
	c:EnableReviveLimit()
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	--prochedure
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetCountLimit(1,210001112)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetCondition(c210001108.sprcondition)
	e2:SetOperation(c210001108.sproperation)
	c:RegisterEffect(e2)
	--cannot attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_ATTACK)
	c:RegisterEffect(e3)
	--cannot be targeted
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
	--replace operation
	local e5=Effect.CreateEffect(c)
	e5:SetCountLimit(1,210001113)
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EVENT_CHAINING)
	e5:SetCondition(c210001108.eccondition)
	e5:SetCost(c210001108.eccost)
	e5:SetTarget(c210001108.ectarget)
	e5:SetOperation(c210001108.ecoperation)
	c:RegisterEffect(e5)
end
function c210001108.sprfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xfed) and c:IsAbleToHandAsCost()
end
function c210001108.sprcondition(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local mg=Duel.GetMatchingGroup(c210001108.sprfilter,tp,LOCATION_MZONE,0,nil)
	return ft>-2 and aux.SelectUnselectGroup(mg,e,tp,2,2,aux.ChkfMMZ(1),0)
end
function c210001108.sproperation(e,tp,eg,ep,ev,re,r,rp,c)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local mg=Duel.GetMatchingGroup(c210001108.sprfilter,tp,LOCATION_MZONE,0,nil)
	local g=aux.SelectUnselectGroup(mg,e,tp,2,2,aux.ChkfMMZ(1),1,tp,HINTMSG_RTOHAND)
	Duel.SendtoHand(g,nil,REASON_COST)
end
function c210001108.eccondition(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return (re:IsActiveType(TYPE_MONSTER) and loc==LOCATION_MZONE)
		or ((re:GetActiveType()==TYPE_SPELL or re:GetActiveType()==TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
function c210001108.eccostfilter(c)
	return c:IsSetCard(0xfed) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function c210001108.eccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210001108.eccostfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
	local g=Duel.SelectMatchingCard(tp,c210001108.eccostfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,0,REASON_COST)
end
function c210001108.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xfed)
end
function c210001108.ectarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210001108.cfilter,rp,0,LOCATION_GRAVE,1,nil) end
end
function c210001108.ecoperation(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,c210001108.repop)
end
function c210001108.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetType()==TYPE_SPELL or c:GetType()==TYPE_TRAP then
		c:CancelToGrave(false)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,c210001108.cfilter,tp,0,LOCATION_GRAVE,1,1,nil)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
