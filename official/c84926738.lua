--雷仙人
--The Immortal of Thunder
local s,id=GetID()
function s.initial_effect(c)
	--Register a flag to this card when it is flipped face-up
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_FLIP)
	e0:SetOperation(function(e) e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1) end)
	c:RegisterEffect(e0)
	--Gain 3000 LP if it is flipped face-up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetOperation(function(_,tp) Duel.Recover(tp,3000,REASON_EFFECT) end)
	c:RegisterEffect(e1)
	--Lose 5000 LP when it is sent to the GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(function(e) return e:GetLabel()>0 end)
	e2:SetOperation(s.lpop)
	c:RegisterEffect(e2)
	--Enable the effect above when it is about to leave the field if it was flipped face-up
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_LEAVE_FIELD_P)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(s.regop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetLP(tp,Duel.GetLP(tp)-5000)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():HasFlagEffect(id) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end