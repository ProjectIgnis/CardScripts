--Aqua Gate
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--negate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_BOTH_SIDE+EFFECT_FLAG_REPEAT)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetLabel(0)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
	--reset
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.rescon)
	e3:SetOperation(s.resop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
function s.filter(c)
	return c:IsFacedown()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tg=Duel.GetAttacker()
	local p=Duel.GetTurnPlayer()
	local g=Duel.GetMatchingGroup(s.filter,1-p,LOCATION_SZONE,0,nil)
	local ct=#g
	local ctn=e:GetLabel()
	if chkc then return chkc==tg end
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING) and Duel.IsExistingMatchingCard(s.filter,1-p,LOCATION_SZONE,0,1,nil)
		and tg:IsOnField() and tg:IsCanBeEffectTarget(e) and ct>0 and ctn<ct end
	Duel.SetTargetCard(tg)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetTurnPlayer()
	local g=Duel.GetMatchingGroup(s.filter,1-p,LOCATION_SZONE,0,nil)
	local ct=#g
	local ctn=e:GetLabel()
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and ct>0 and ctn<ct and Duel.SelectYesNo(1-p,aux.Stringid(id,REASON_EFFECT)) then
		Duel.NegateAttack()
		e:SetLabel(ctn+1)
	end
end
function s.rescon(e)
	return e:GetLabelObject():GetLabel()>0
end
function s.resop(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(0)
end
