--
--Eternal Chaos
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--Send to grave
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
end
function s.rescon(atk)
	return function(sg,e,tp,mg)
		return sg:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_DARK) and sg:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_LIGHT)
			and sg:GetSum(Card.GetAttack)<=atk
	end
end
function s.tgfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK+ATTRIBUTE_LIGHT) and c:IsAbleToGrave()
end
function s.cfilter(c,e,tp,g)
	return c:IsFaceup() and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon(c:GetAttack()),0)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.cfilter(chkc,e,tp,g) end
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,0,LOCATION_MZONE,1,nil,e,tp,g) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.cfilter,tp,0,LOCATION_MZONE,1,1,false,nil,e,tp,g)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--activate limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAINING)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetOperation(s.aclimit1)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHAIN_NEGATED)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetOperation(s.aclimit2)
	Duel.RegisterEffect(e2,tp)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetTargetRange(1,0)
	e3:SetReset(RESET_PHASE+PHASE_END)
	e3:SetCondition(s.econ)
	e3:SetValue(s.elimit)
	Duel.RegisterEffect(e3,tp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon(tc:GetAttack()),1,tp,HINTMSG_TOGRAVE,nil,nil)
	if #tg>0 then
		Duel.SendtoGrave(tg,REASON_EFFECT)
	end
end
function s.aclimit1(e,tp,eg,ep,ev,re,r,rp)
	if ep~=tp or not re:GetActivateLocation()==LOCATION_GRAVE or not re:IsActiveType(TYPE_MONSTER) then return end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
function s.aclimit2(e,tp,eg,ep,ev,re,r,rp)
	if ep~=tp or not re:GetActivateLocation()==LOCATION_GRAVE or not re:IsActiveType(TYPE_MONSTER) then return end
	Duel.ResetFlagEffect(tp,id)
end
function s.econ(e)
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)~=0
end
function s.elimit(e,te,tp)
	return te:GetActivateLocation()==LOCATION_GRAVE and te:IsActiveType(TYPE_MONSTER)
end