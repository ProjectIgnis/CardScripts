--オーバーレイ・サテライト
--Overlay Satellite
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--Treat the equipped monster as 2 Xyz Materials
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_DOUBLE_XYZ_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Attach this card to an Xyz monster Summoned using the attached monster as material
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(s.atcon)
	e2:SetTarget(s.attg)
	e2:SetOperation(s.atop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
end
function s.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetPreviousEquipTarget()
	if c:IsReason(REASON_LOST_TARGET) and tc and tc:IsReason(REASON_XYZ) then
		e:SetLabelObject(tc:GetReasonCard())
		return true
	else
		return false
	end
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if chk==0 then return tc and c:IsCanBeXyzMaterial(tc,tp,REASON_EFFECT) end
	tc:CreateEffectRelation(e)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if not (c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)) then return end
	Duel.Overlay(tc,c)
	--This card cannot attack this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(3206)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	tc:RegisterEffect(e1)
end