--Briar Pin-Seal
--coded by Lyris
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--forbidden
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_FORBIDDEN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0x7f,0x7f)
	e2:SetCondition(s.bancon)
	e2:SetTarget(s.bantg)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_DISCARD_HAND)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(1,1)
	e3:SetCondition(s.bancon)
	e3:SetTarget(s.bantg)
	e3:SetLabelObject(e1)
	c:RegisterEffect(e3)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	e:SetLabelObject(nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND):Select(tp,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	Duel.HintSelection(g)
	tc:RegisterFlagEffect(id,RESET_EVENT+0x1de0000,0,0)
	e:SetLabelObject(tc)
	Duel.AdjustInstantly(c)
end
function s.bancon(e)
	return e:GetHandler():GetFlagEffect(id)>0
end
function s.bantg(e,c,re,r)
	return c==e:GetLabelObject():GetLabelObject() and c:GetFlagEffect(id)>0
end
