--ワーム・イリダン
--Worm Illidan
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0xf)
	--add counter
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_MSET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.accon1)
	e1:SetOperation(s.acop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SSET)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_CHANGE_POS)
	e3:SetCondition(s.accon2)
	c:RegisterEffect(e3)
	local e4=e1:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(s.accon3)
	c:RegisterEffect(e4)
	--destroy
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCost(s.descost)
	e5:SetTarget(s.destg)
	e5:SetOperation(s.desop)
	c:RegisterEffect(e5)
end
s.counter_place_list={0xf}
function s.accon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst():IsControler(tp)
end
function s.filter2(c,tp)
	return c:IsControler(tp) and (c:GetPreviousPosition()&POS_FACEUP)~=0 and (c:GetPosition()&POS_FACEDOWN)~=0
end
function s.accon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter2,1,nil,tp)
end
function s.filter3(c,tp)
	return c:IsControler(tp) and c:IsFacedown()
end
function s.accon3(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter3,1,nil,tp)
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0xf,1)
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0xf,2,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0xf,2,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
