--オーバーレイ・サテライト
--Overlay Satellite
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--Treat the equipped monster as 2 Xyz Materials
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(511001225)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Attach this card to an Xyz monster Summoned using the attached monster as material
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetRange(LOCATION_GRAVE|LOCATION_REMOVED)
	e2:SetCondition(s.atcon)
	e2:SetTarget(s.attg)
	e2:SetOperation(s.atop)
	c:RegisterEffect(e2)
end
function s.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetPreviousEquipTarget()
	return c:IsReason(REASON_LOST_TARGET) and c:IsPreviousLocation(LOCATION_SZONE) and rc and eg:IsContains(rc) and rc:IsReason(REASON_XYZ)
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	Duel.SetTargetCard(c:GetPreviousEquipTarget():GetReasonCard())
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local rc=c:GetPreviousEquipTarget():GetReasonCard()
	if not rc:IsRelateToEffect(e) then return end
	Duel.Overlay(rc,c)
	--Cannot attack this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(3206)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	rc:RegisterEffect(e1)
end
