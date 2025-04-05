--Ａ・Ɐ・ＶＶ
--Amaze Attraction Viking Vortex
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--From cards_specific_functions.lua
	aux.AddAttractionEquipProc(c)
	--You
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetCountLimit(1)
	e1:SetCondition(aux.AttractionEquipCon(true))
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	--Your opponent
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(aux.AttractionEquipCon(false))
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	local tg=Duel.GetAttacker()
	if chk==0 then return tp==1-Duel.GetTurnPlayer() and tg and tg:IsOnField() and ec:IsControlerCanBeChanged() end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,ec,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local ec=e:GetHandler():GetEquipTarget()
	if Duel.NegateAttack() and ec:IsControlerCanBeChanged() then
		Duel.GetControl(ec,1-ec:GetControler(),PHASE_BATTLE,1)
	end
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	if chk==0 then return re:GetHandler()==ec and ec:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,ec,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local ec=e:GetHandler():GetEquipTarget()
	if ec then
		Duel.SendtoHand(ec,nil,REASON_EFFECT)
	end
end