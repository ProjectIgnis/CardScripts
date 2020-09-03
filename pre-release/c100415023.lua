--Evil★Twin プレゼント
--Evil★Twin Present
--Scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Switch control
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END+TIMING_END_PHASE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.conttg)
	e1:SetOperation(s.contop)
	c:RegisterEffect(e1)
	--Shuffle a target into the Deck
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
s.listed_series={0x24c,0x24d}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0):Filter(Card.IsFaceup,nil)
	return g:IsExists(Card.IsSetCard,1,nil,0x24c) and g:IsExists(Card.IsSetCard,1,nil,0x24d)
end
function s.filter1(c)
	return c:IsFaceup() and (c:IsSetCard(0x24c) or c:IsSetCard(0x24d)) and c:IsAbleToChangeControler()
end
function s.filter2(c)
	return c:IsFaceup() and c:IsAbleToChangeControler()
end
function s.conttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.filter2,tp,0,LOCATION_MZONE,1,nil)
		and Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g1=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g2=Duel.SelectTarget(tp,s.filter2,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g1,2,0,0)
end
function s.contop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	local a=g:GetFirst()
	local b=g:GetNext()
	if a:IsRelateToEffect(e) and b:IsRelateToEffect(e) then
		Duel.SwapControl(a,b)
	end
end
function s.filter3(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and s.filter3(chkc) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter3,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.filter3,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
	end
end
