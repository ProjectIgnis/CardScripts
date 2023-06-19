--アーマード・エクシーズ
--Armored Xyz
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Equip 1 Xyz monster to another monster on the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.eqfilter(c)
	return c:IsType(TYPE_XYZ) and not c:IsForbidden()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:GetHandler():IsLocation(LOCATION_HAND) then ft=ft-1 end
	if chk==0 then return ft>0 and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local eqc=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,eqc,1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local g=Duel.GetTargetCards(e)
	if #g~=2 then return end
	local tc=g:Filter(Card.IsLocation,nil,LOCATION_MZONE):GetFirst()
	local eqc=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE):GetFirst()
	if tc and eqc then
		if not tc:EquipByEffectAndLimitRegister(e,tp,eqc,nil,true) then return end
		local atk=eqc:GetTextAttack()
		local att=eqc:GetAttribute()
		--Equip limit
		local e0=Effect.CreateEffect(eqc)
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e0:SetCode(EFFECT_EQUIP_LIMIT)
		e0:SetValue(function(e,c) return c==tc end)
		e0:SetReset(RESET_EVENT|RESETS_STANDARD)
		eqc:RegisterEffect(e0)
		--ATK becomes the equipped monster's
		local e1=Effect.CreateEffect(eqc)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		eqc:RegisterEffect(e1)
		--Gains the attribute of the equipped monster
		local e2=e1:Clone()
		e2:SetCode(EFFECT_ADD_ATTRIBUTE)
		e2:SetValue(att)
		eqc:RegisterEffect(e2)
		--Second attack in a row
		local e3=Effect.CreateEffect(eqc)
		e3:SetDescription(aux.Stringid(id,1))
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e3:SetCode(EVENT_DAMAGE_STEP_END)
		e3:SetRange(LOCATION_SZONE)
		e3:SetCondition(s.atkcon)
		e3:SetCost(s.atkcost)
		e3:SetOperation(function() Duel.ChainAttack() end)
		e3:SetReset(RESET_EVENT|RESETS_STANDARD)
		eqc:RegisterEffect(e3)
	end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec==Duel.GetAttacker() and ec:CanChainAttack()
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	Duel.SendtoGrave(c,REASON_COST)
end