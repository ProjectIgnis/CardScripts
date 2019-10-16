--レッド・スプレマシー
--Red Supremacy
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x1045}
s.check=false
function s.cfilter(c,tp)
	local code=c:GetOriginalCode()
	return c:IsSetCard(0x1045) and c:IsType(TYPE_SYNCHRO) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true) 
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,c,code)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	s.check=true
	return true
end
function s.filter(c,code)
	return c:IsFaceup() and c:IsSetCard(0x1045) and c:IsType(TYPE_SYNCHRO) and (not c:IsCode(code) or not c:IsOriginalCode(code))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,e:GetLabel()) end
	if chk==0 then
		if not s.check then return false end
		s.check=false
		return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	local code=g:GetFirst():GetOriginalCode()
	e:SetLabel(code)	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,code)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local code=e:GetLabel()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(code)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc:ReplaceEffect(code,RESET_EVENT+RESETS_STANDARD)
	end
end
