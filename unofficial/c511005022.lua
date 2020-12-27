--Bond's Reward
--	By Shad3
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DAMAGE)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.fld_fil(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end

function s.grv_fil(c)
	return c:IsAbleToRemove() and c:IsType(TYPE_SYNCHRO) and aux.SpElimFilter(c,true)
end

function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,69832741) and Duel.IsExistingTarget(s.fld_fil,tp,LOCATION_MZONE,0,1,nil) 
	and Duel.IsExistingMatchingCard(s.grv_fil,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SelectTarget(tp,s.fld_fil,tp,LOCATION_MZONE,0,1,1,nil)
end

function s.grv_lvl_sum(c)
	return c:GetLevel()*200
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local tg=Duel.GetFieldGroup(tp,LOCATION_GRAVE,0):Filter(s.grv_fil,nil)
	if tc:IsRelateToEffect(e) and #tg>0 then
		if not Duel.Remove(tg,nil,REASON_EFFECT) then return end
		local i=tg:Filter(Card.IsLocation,nil,LOCATION_REMOVED):GetSum(s.grv_lvl_sum)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(i)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetReset(RESET_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetOperation(s.dmg_op)
		e2:SetLabel(i)
		Duel.RegisterEffect(e2,tp)
	end
end

function s.dmg_op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(tp,e:GetLabel(),REASON_EFFECT)
end
