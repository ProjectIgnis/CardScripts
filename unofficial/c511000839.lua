--Dodge Roll
local s,id=GetID()
function s.initial_effect(c)
	--
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_AVAILABLE_BD)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.refcon)
	e1:SetLabel(0)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_AVAILABLE_BD)
	e2:SetTargetRange(0,1)
	e2:SetLabelObject(e1)
	e2:SetValue(s.refcon)
	e2:SetLabel(0)
	Duel.RegisterEffect(e2,tp)
	e1:SetLabelObject(e2)
end
function s.refcon(e,re,val,r,rp,rc)
	if val>0 and e:GetLabel()==0 then
		e:GetLabelObject():SetLabel(1)
		e:Reset()
		return 0
	end
	if e:GetLabel()==1 then
		e:Reset()
	end
	return val
end
