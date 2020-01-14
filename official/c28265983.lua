--渇きの風
--Dried Winds
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EVENT_RECOVER)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.descon1)
	e1:SetTarget(s.destg1)
	e1:SetOperation(s.desop1)
	c:RegisterEffect(e1)
	--destroy
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,4))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+1)
	e3:SetCondition(s.descon2)
	e3:SetCost(s.descost2)
	e3:SetTarget(s.destg2)
	e3:SetOperation(s.desop2)
	c:RegisterEffect(e3)
end
s.listed_series={0xc9}
function s.descon1(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
function s.destg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop1(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function s.descon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsSetCard,0xc9),tp,LOCATION_MZONE,0,1,nil) and Duel.GetLP(tp)-Duel.GetLP(1-tp)>=3000
end
function s.descost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local lp=Duel.GetLP(tp)-Duel.GetLP(1-tp)
	if chk==0 then return Duel.CheckLPCost(tp,lp) end
	Duel.PayLPCost(tp,lp)
	e:SetLabel(lp)
end
function s.desfilter2(c,num)
	return c:IsFaceup() and c:IsAttackBelow(num)
end
function s.destg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local lp=Duel.GetLP(tp)-Duel.GetLP(1-tp)
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter2,tp,0,LOCATION_MZONE,1,nil,lp) end
	local g=Duel.GetMatchingGroup(s.desfilter2,tp,0,LOCATION_MZONE,nil,e:GetLabel())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.rescon(lp)
	return function(sg,e,tp,mg)
		return sg:GetSum(Card.GetAttack)<=lp
	end
end
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local num=e:GetLabel()
	local g=Duel.GetMatchingGroup(s.desfilter2,tp,0,LOCATION_MZONE,nil,num)
	if #g==0 then return end
	local dg=aux.SelectUnselectGroup(g,e,tp,1,nil,s.rescon(num),1,tp,HINTMSG_DESTROY)
	Duel.Destroy(dg,REASON_EFFECT)
end
