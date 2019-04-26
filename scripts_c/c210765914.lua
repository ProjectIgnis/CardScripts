--Sayuri & 3L
local m=210765914
local cm=_G["c"..m]
xpcall(function() require("expansions/script/c210765765") end,function() require("script/c210765765") end)
cm.Senya_name_with_sayuri=true
function cm.initial_effect(c)
	--Senya.CommonEffect_3L(c,m)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_RITUAL_LEVEL)
	e1:SetValue(function(e,c)
		local lv=e:GetHandler():GetLevel()
		if Senya.check_set_sayuri(c) then
			local clv=c:GetLevel()
			return lv*65536+clv
		else return lv end
	end)
	c:RegisterEffect(e1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(m)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(cm.condition)
	e2:SetOperation(cm.operation)
	c:RegisterEffect(e2)
end
function cm.effect_operation_3L(c,ctlm)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,0x1c0)
	e1:SetCountLimit(ctlm)
	e1:SetCost(Senya.DescriptionCost())
	e1:SetTarget(cm.target1)
	e1:SetOperation(cm.operation1)
	e1:SetReset(RESET_EVENT+0x1fe0000)
	c:RegisterEffect(e1,true)
	return e1
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_RITUAL
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	for rc in aux.Next(eg) do
		if Senya.check_set_sayuri(rc) and Senya.EffectSourceFilter_3L(e:GetHandler(),rc) then
			Senya.GainEffect_3L(rc,e:GetHandler())
		end
	end
end
function cm.filter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
function cm.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and cm.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cm.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,cm.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function cm.operation1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end