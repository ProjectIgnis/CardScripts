--メタモル・クレイ・フォートレス
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(4)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,0x21,1000,1000,4,RACE_ROCK,ATTRIBUTE_EARTH) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,0x21,1000,1000,4,RACE_ROCK,ATTRIBUTE_EARTH) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP)
	c:AddMonsterAttributeComplete()
	--position
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetCondition(s.poscon)
	e1:SetOperation(s.posop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1,true)
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2,true)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3,true)
	Duel.SpecialSummonComplete()
	aux.AddEREquipLimit(c,nil,s.eqval,s.equipop,e,nil,RESET_EVENT+RESETS_STANDARD)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.BreakEffect()
		s.equipop(c,e,tp,tc)
	end
end
function s.eqval(ec,c,tp)
	return ec:IsControler(tp) and ec:IsLevelAbove(4)
end
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler()==Duel.GetAttacker() and e:GetHandler():IsRelateToBattle()
end
function s.equipop(c,e,tp,tc)
	aux.EquipByEffectAndLimitRegister(c,e,tp,tc,id)		
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
function s.atkval(e,c)
	local g=e:GetHandler():GetEquipGroup():Filter(s.eqfilter,nil)
	local atk=0
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		local tatk=tc:GetAttack()
		if tatk>0 then atk=atk+tatk end
	end
	return atk
end
function s.eqfilter(c)
	return c:GetFlagEffect(id)~=0 
end
