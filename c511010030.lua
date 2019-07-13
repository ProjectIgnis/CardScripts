--No.30 破滅のアシッド・ゴーレム
Duel.LoadCardScript("c81330115.lua")
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_LIGHT),3,2)
	c:EnableReviveLimit()
	--remove material
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81330115,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.rmcon)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	--cannot attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetCondition(s.atcon)
	c:RegisterEffect(e2)
	--material
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(s.olcon)
	e3:SetTarget(s.oltg)
	e3:SetOperation(s.olop)
	c:RegisterEffect(e3)
	--battle indestructable
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetValue(s.indes)
	c:RegisterEffect(e4)
end
s.xyz_number=30
function s.atcon(e)
	return e:GetHandler():GetOverlayCount()==0
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if e:GetHandler():GetOverlayCount()==0 then
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,2000)
	end
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT) and Duel.SelectYesNo(tp,aux.Stringid(81330115,1)) then
		e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	else
		Duel.Damage(tp,2000,REASON_EFFECT)
	end
end

function s.olcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayCount()==0
end
function s.oltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
if chk==0 then return true end
	if e:GetHandler():GetOverlayCount()==0 then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,2000)
	end
end
function s.olop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		if Duel.Destroy(c,REASON_EFFECT)~=0 then
		Duel.Damage(tp,2000,REASON_EFFECT)
		end
	end
end
function s.indes(e,c)
	return not c:IsSetCard(0x48)
end