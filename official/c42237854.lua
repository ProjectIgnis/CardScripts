--機動要塞 メタル・ホールド
--Metalhold the Moving Blockade
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--atk limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(s.con)
	e2:SetValue(s.atlimit)
	c:RegisterEffect(e2)
	--cannot be target
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(s.con)
	e3:SetTarget(s.tgtg)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
end
function s.con(e,tp,eg,ep,ev,re,r,rp,chk)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL+1)
end
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:GetLevel()==4
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,0x21,0,0,4,RACE_MACHINE,ATTRIBUTE_EARTH) end
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,ft,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,#g,0,0)
end
function s.tgfilter(c,e)
	return c:IsFaceup() and c:IsRelateToEffect(e)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,0x21,0,0,4,RACE_MACHINE,ATTRIBUTE_EARTH) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	Duel.SpecialSummonStep(c,1,tp,tp,true,false,POS_FACEUP)
	--atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	c:AddMonsterAttributeComplete()
	Duel.SpecialSummonComplete()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(s.tgfilter,nil,e)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	aux.AddEREquipLimit(c,nil,s.eqval,s.equipop,e,nil,RESET_EVENT+RESETS_STANDARD_DISABLE)
	if #g<=0 or ft<=0 then return end
	local tg=nil
	if ft<#g then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		tg=g:FilterSelect(tp,s.filter,ft,ft,nil)
	else
		tg=g:Clone()
	end
	if #tg>0 then
		Duel.BreakEffect()
		local tc=tg:GetFirst()
		for tc in aux.Next(tg) do
			s.equipop(c,e,tp,tc,true)
		end
		Duel.EquipComplete()
	end
end
function s.eqval(ec,c,tp)
	return ec:IsControler(tp) and ec:IsRace(RACE_MACHINE) and ec:GetLevel()==4
end
function s.equipop(c,e,tp,tc,chk)
	local eff=false or chk
	Duel.Equip(tp,tc,c,false,eff)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(aux.EquipByEffectLimit)
	e1:SetLabelObject(e:GetLabelObject())
	tc:RegisterEffect(e1)
	tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
end
function s.atkval(e,c)
	local atk=0
	local g=c:GetEquipGroup()
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		if tc:GetFlagEffect(id)~=0 and tc:GetAttack()>=0 then
			atk=atk+tc:GetAttack()
		end
	end
	return atk
end
function s.atlimit(e,c)
	return c~=e:GetHandler()
end
function s.tgtg(e,c)
	return c~=e:GetHandler()
end