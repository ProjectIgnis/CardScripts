--スーパービークロイド－ステルス・ユニオン
--Super Vehicroid - Stealth Union
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,61538782,98049038,71218746,984114)
	--equip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	aux.AddEREquipLimit(c,nil,aux.NOT(aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE)),s.equipop,e1)
	--attack all
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetCondition(s.atcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--pierce
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e3)
	--atk
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
end
s.material_setcode=0x16
function s.eqfilter(c,tp)
	return c:IsFaceup() and not c:IsRace(RACE_MACHINE) and (c:IsControler(tp) or c:IsAbleToChangeControler())
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.eqfilter(chkc,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler(),tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler(),tp)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function s.equipop(c,e,tp,tc)
	if not aux.EquipByEffectAndLimitRegister(c,e,tp,tc) then return end
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(id)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e2)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) and not tc:IsRace(RACE_MACHINE) and tc:IsRelateToEffect(e) then
		s.equipop(c,e,tp,tc)
	end
end
function s.atcon(e)
	return e:GetHandler():IsHasEffect(id)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local atk=c:GetBaseAttack()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
	e1:SetValue(atk/2)
	c:RegisterEffect(e1)
end
