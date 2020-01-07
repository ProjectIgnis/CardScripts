--Lira the Giver
local s,id=GetID()
function s.initial_effect(c)
	--Give Counter
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98162021,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.addct2)
	e1:SetOperation(s.addc2)
	c:RegisterEffect(e1)
end
function s.addct2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1109,1,REASON_EFFECT)
		and Duel.IsExistingTarget(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler(),0x1109,1) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(98162021,1))
	Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler(),0x1109,1)
end
function s.addc2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetCounter(0x1109)==0 then return end
	c:RemoveCounter(tp,0x1109,1,REASON_EFFECT)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:AddCounter(0x1109,1)
	end
end
