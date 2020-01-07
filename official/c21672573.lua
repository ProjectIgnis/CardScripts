--エンペラー・ストゥム
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.tdcon1)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_MSET)
	e2:SetCondition(s.tdcon2)
	c:RegisterEffect(e2)
end
function s.tdcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst()~=e:GetHandler() and ep==tp
		and eg:GetFirst():IsSummonType(SUMMON_TYPE_TRIBUTE)
end
function s.tdcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst():GetMaterialCount()~=0 and ep==tp
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g1=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,1,1,nil)
	if Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,nil)
		and Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TODECK)
		local g2=Duel.SelectTarget(1-tp,Card.IsAbleToDeck,1-tp,LOCATION_GRAVE,0,1,1,nil)
		g1:Merge(g2)
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,#g1,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or e:GetHandler():IsFacedown() then return end
	local g=Duel.GetTargetCards(e)
	Duel.SendtoDeck(g,nil,0,REASON_EFFECT)
end
