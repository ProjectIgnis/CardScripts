--Ｓｐ－アクセル・リミッター
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.turncon1(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer() and Duel.GetTurnCount()~=e:GetLabel() and Duel.GetCurrentPhase()==PHASE_STANDBY
end
function s.turncon2(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer() and Duel.GetCurrentPhase()==PHASE_STANDBY
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local res
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(100100090)
	e1:SetTargetRange(0,1)
	if Duel.GetTurnPlayer()~=tp and Duel.GetCurrentPhase()==PHASE_STANDBY then
		res=3
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(s.turncon1)
	else
		res=2
		e1:SetCondition(s.turncon2)
	end
	e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_OPPO_TURN,res)
	e1:SetValue(0)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetLabel(0)
	e2:SetValue(res)
	e2:SetCondition(s.turncon)
	e2:SetOperation(s.turnop)
	e2:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_OPPO_TURN,res)
	Duel.RegisterEffect(e2,tp)
	e2:SetLabelObject(e1)
	local descnum=tp==c:GetOwner() and 0 or 1
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e3:SetCode(1082946)
	e3:SetLabelObject(e2)
	e3:SetDescription(aux.Stringid(4931121,descnum))
	e3:SetOperation(s.reset)
	e3:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_OPPO_TURN,res)
	c:RegisterEffect(e3)
end
function s.reset(e,tp,eg,ep,ev,re,r,rp)
	s.turnop(e:GetLabelObject(),tp,eg,ep,ev,e,r,rp)
end
function s.turncon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function s.turnop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	if e:GetValue()==3 then
		e:SetValue(0)
		ct=ct-1
		e:GetLabelObject():SetCondition(s.turncon2)
	end
	ct=ct+1
	e:SetLabel(ct)
	if ev==1082946 then
		e:GetHandler():SetTurnCounter(ct)
	end
	if ct==2 then
		e:GetLabelObject():Reset()
		if re then re:Reset() end
	end
end
