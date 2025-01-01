--亜空間物質回送装置
--Interdimensional Matter Forwarder
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Banish a monster and return it to the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.rmvtg(s.rmvfilter1))
	e1:SetOperation(s.rmvop)
	c:RegisterEffect(e1)
	--Banish a monster that has its effects negated and return it to the field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp,eg,ep) return ep==1-tp end)
	e2:SetTarget(s.rmvtg(s.rmvfilter2))
	e2:SetOperation(s.rmvop)
	c:RegisterEffect(e2)
	--Banish this card until the End Phase of the next turn before resolving an opponent's card effect that targets it
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.selfrmvcon)
	e3:SetOperation(s.selfrmvop)
	c:RegisterEffect(e3)
end
function s.rmvfilter1(c)
	return c:IsAbleToRemove() and Duel.GetMZoneCount(c:GetControler(),c)>0
end
function s.rmvfilter2(c)
	return c:IsDisabled() and c:IsType(TYPE_EFFECT) and c:IsAbleToRemove() and Duel.GetMZoneCount(c:GetControler(),c)>0
end
function s.rmvtg(filter)
	return function (e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		if chkc then return chkc:IsLocation(LOCATION_MZONE) and filter(chkc) end
		if chk==0 then return Duel.IsExistingTarget(filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectTarget(tp,filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,0)
	end
end
function s.rmvop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,nil,REASON_EFFECT|REASON_TEMPORARY)>0 and tc:IsLocation(LOCATION_REMOVED)
		and not tc:IsReason(REASON_REDIRECT) then
		Duel.BreakEffect()
		Duel.ReturnToField(tc)
	end
end
function s.selfrmvcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (ep==1-tp and c:IsAbleToRemove() and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsContains(c)
end
function s.selfrmvop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,1-tp,id)
	local ct=Duel.GetTurnCount()
	aux.RemoveUntil(e:GetHandler(),nil,REASON_EFFECT,PHASE_END,id,e,tp,aux.DefaultFieldReturnOp,function() return Duel.GetTurnCount()==ct+1 end,nil,2)
end