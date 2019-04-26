--Tinsight Salvo
--AlphaKretin
function c210310211.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c210310211.target)
	e1:SetOperation(c210310211.operation)
	c:RegisterEffect(e1)
end
function c210310211.filter(c)
	return c:IsSetCard(0xf35) and c:IsFaceup()
end
function c210310211.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_SZONE,LOCATION_SZONE,1,e:GetHandler()) 
		and Duel.IsExistingMatchingCard(c210310211.filter,tp,LOCATION_ONFIELD,0,1,nil) end
	local num=Duel.GetMatchingGroupCount(c210310211.filter,tp,LOCATION_ONFIELD,0,e:GetHandler())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_SZONE,LOCATION_SZONE,1,num,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function c210310211.operation(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	Duel.Destroy(tg,REASON_EFFECT)
end