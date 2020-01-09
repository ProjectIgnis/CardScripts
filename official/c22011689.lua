--捕食植物モーレイ・ネペンテス
--Predaplant Moray Nepenthes
local s,id=GetID()
function s.initial_effect(c)
	--atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	--equip
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCondition(aux.bdocon)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	aux.AddEREquipLimit(c,nil,aux.FilterBoolFunction(Card.IsType,TYPE_MONSTER),s.equipop,e2)
	--destroy + lp gain
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_RECOVER)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
s.counter_list={COUNTER_PREDATOR}
function s.atkval(e,c)
	return Duel.GetCounter(0,1,1,COUNTER_PREDATOR)*200
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	local bc=e:GetHandler():GetBattleTarget()
	Duel.SetTargetCard(bc)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,bc,1,0,0)
end
function s.equipop(c,e,tp,tc)
	aux.EquipByEffectAndLimitRegister(c,e,tp,tc,id)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		s.equipop(c,e,tp,tc)
	end
end
function s.desfilter(c,ec)
	return c:GetFlagEffect(id)~=0 and c:GetEquipTarget()==ec and (c:GetOriginalType()&TYPE_MONSTER)~=0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and s.desfilter(chkc,c) end
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_SZONE,0,1,nil,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_SZONE,0,1,1,nil,c)
	local atk=g:GetFirst():GetTextAttack()
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	if atk>0 then
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,atk)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		local atk=tc:GetTextAttack()
		Duel.Recover(tp,atk,REASON_EFFECT)
	end
end
