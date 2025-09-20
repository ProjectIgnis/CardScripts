--地底のアラクネー
--Underground Arachnid
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: 1 DARK Tuner + 1 non-Tuner Insect monster
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_DARK),1,1,Synchro.NonTunerEx(Card.IsRace,RACE_INSECT),1,1)
	--If this card attacks, your opponent cannot activate Spells/Traps until the end of the Damage Step
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetCondition(function(e) return Duel.GetAttacker()==e:GetHandler() end)
	e1:SetValue(function(e,re,tp) return re:IsHasType(EFFECT_TYPE_ACTIVATE) end)
	c:RegisterEffect(e1)
	--Equip 1 opponent's face-up monster to this card (only 1 monster can be equipped to this card with this effect)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.eqcon)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	aux.AddEREquipLimit(c,s.eqcon,function(ec,c,tp) return ec:IsControler(1-tp) end,function(c,e,tp,tc) c:EquipByEffectAndLimitRegister(e,tp,tc,id) end,e2)
	--If this card would be destroyed by battle, you can destroy that equipped monster instead
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.desreptg)
	e3:SetOperation(s.desrepop)
	c:RegisterEffect(e3)
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():GetEquipGroup():IsExists(Card.HasFlagEffect,1,nil,id)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToChangeControler() and chkc:IsFaceup() end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(aux.FaceupFilter(Card.IsAbleToChangeControler),tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsAbleToChangeControler),tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,tp,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsControler(1-tp) and tc:IsFaceup() and tc:IsMonster() then
		e:GetHandler():EquipByEffectAndLimitRegister(e,tp,tc,id)
	end
end
function s.desrepfilter(c,e)
	return c:HasFlagEffect(id) and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE) and c:GetEquipGroup():IsExists(s.desrepfilter,1,nil,e) end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipGroup():Match(s.desrepfilter,nil,e)
	Duel.Destroy(ec,REASON_EFFECT|REASON_REPLACE)
end