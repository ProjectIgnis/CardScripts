--精神汚染
local s,id=GetID()
function s.initial_effect(c)
	--control
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.ctffilter(c,lv)
	return c:IsFaceup() and c:IsControlerCanBeChanged() and c:GetLevel()==lv
end
function s.ctfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsDiscardable()
		and Duel.IsExistingTarget(s.ctffilter,tp,0,LOCATION_MZONE,1,nil,c:GetLevel())
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.ctffilter(chkc,e:GetLabel()) end
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.ctfilter,tp,LOCATION_HAND,0,1,nil,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local sg=Duel.SelectMatchingCard(tp,s.ctfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	local lv=sg:GetFirst():GetLevel()
	e:SetLabel(lv)
	Duel.SendtoGrave(sg,REASON_COST+REASON_DISCARD)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,s.ctffilter,tp,0,LOCATION_MZONE,1,1,nil,lv)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:GetLevel()==e:GetLabel() then
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
