--豆まき
--Mamemaki
--
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_DRAW+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,tp)
	local lv=c:GetLevel()
	return lv>0 and c:IsFaceup() and c:IsAbleToDeck() and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>=lv and Duel.IsPlayerCanDraw(tp,lv)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	local lv=g:GetFirst():GetLevel()
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,lv)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,lv)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local lv=tc:GetLevel()
	if tc:IsRelateToEffect(e) and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>=lv then
		local ct=Duel.DiscardHand(tp,aux.TRUE,lv,lv,REASON_EFFECT|REASON_DISCARD)
		if ct>0 and Duel.Draw(tp,lv,REASON_EFFECT)~=0 then
			Duel.BreakEffect()
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end