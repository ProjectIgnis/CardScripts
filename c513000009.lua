--死のデッキ破壊ウイルス (Anime)
--Crush Card Virus (Anime)
--Updated by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAttackBelow(1000) and c:IsFaceup()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		--Virus
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_DESTROYED)
		e1:SetCountLimit(1)
		e1:SetLabelObject(tc)
		e1:SetCondition(s.descon)
		e1:SetOperation(s.desop)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EVENT_DESTROY)
		e2:SetLabelObject(e1)
		e2:SetOperation(s.checkop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
	end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(1)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetLabelObject()
	return e:GetLabel()==1 and c:GetPreviousAttributeOnField()&ATTRIBUTE_DARK==ATTRIBUTE_DARK
		and c:GetPreviousAttackOnField()<=1000 and c:GetPreviousControler()==tp
end
function s.desfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttackAbove(1500)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local conf=Duel.GetFieldGroup(tp,0,LOCATION_MZONE+LOCATION_HAND+LOCATION_DECK)
	if #conf>0 then
		Duel.ConfirmCards(tp,conf)
		local dg=conf:Filter(s.desfilter,nil)
		Duel.Destroy(dg,REASON_EFFECT)
		Duel.ShuffleHand(1-tp)
	end
	e:SetLabel(0)
	e:Reset()
end
