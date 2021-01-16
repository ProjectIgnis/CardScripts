--ベアルクティ・ビッグディッパー
--Bearcti Big Dipper
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x204)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--tribute substitute
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_RELEASE_REPLACE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_GRAVE,0)
	e2:SetCountLimit(1)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
	--add counter
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetOperation(s.countop)
	c:RegisterEffect(e3)
	--control
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_CONTROL)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.ctcon)
	e4:SetCost(s.ctcost)
	e4:SetTarget(s.cttg)
	e4:SetOperation(s.ctop)
	c:RegisterEffect(e4)
end
s.listed_series={0x25b }
s.counter_place_list={0x204 }
function s.repfilter(c,tp,re)
	local rc=re:GetHandler()
	return re:IsActivated() and re:IsActiveType(TYPE_MONSTER) and rc and rc:IsSetCard(0x25b) 
		and c:IsReason(REASON_COST) and c:IsType(TYPE_MONSTER) and not c:IsReason(REASON_REPLACE)
end
function s.repcfilter(c)
	return c:IsSetCard(0x25b) and c:IsLevelAbove(7) and c:IsAbleToRemoveAsCost()
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp,re)
		and Duel.IsExistingMatchingCard(s.repcfilter,tp,LOCATION_GRAVE,0,1,nil) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler())
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer(),c:GetReasonEffect())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.repcfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST+REASON_REPLACE)
end
function s.countop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x204,1)
end
function s.ctcfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsSetCard(0x25b)
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.ctcfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanRemoveCounter(tp,0x204,7,REASON_COST) end
	c:RemoveCounter(tp,0x204,c:GetCounter(0x204),REASON_COST)
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsControlerCanBeChanged() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and e:GetHandler():IsRelateToEffect(e) then
		Duel.GetControl(tc,tp)
	end
end
