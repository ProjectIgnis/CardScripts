--The Beast That Lurks in the Waters
--designed by Thaumablazer#4134, scripted by Naim
--local s,id=GetID()
function c210777063.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(c210777063.spcon)
	e1:SetOperation(c210777063.spop)
	c:RegisterEffect(e1)
	--immune
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c210777063.efilter)
	c:RegisterEffect(e2)
	--gy effect (shuffle monster)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,210777063+100)
	e3:SetCost(aux.bfgcost)
	e3:SetCondition(c210777063.tdcond)
	e3:SetTarget(c210777063.tdtg)
	e3:SetOperation(c210777063.tdop)
	c:RegisterEffect(e3)
end
function c210777063.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_HAND,0,1,c)
end
function c210777063.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,1,1,c)
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
function c210777063.efilter(e,re)
	local cg=e:GetHandler():GetColumnGroup()
	local typecheck=0
	for tc in aux.Next(cg) do
		typecheck = typecheck | (tc:GetType()&(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP))
	end
	return typecheck~=0 and re:IsActiveType(typecheck)
end
function c210777063.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf10) and not c:IsCode(210777063)
end
function c210777063.tdcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c210777063.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c210777063.desfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function c210777063.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(c210777063.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,c210777063.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function c210777063.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
	end
end

