--セイヴァー・アブソープション
--Majestic Absorption
--scripted by Rundas
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP+CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
s.listed_names={id,44508094}
s.listed_series={0x3f}
--To Grave
function s.tgfilter(c,tp)
	return c:IsCode(44508094) or (aux.IsCodeListed(c,44508094) and c:IsType(TYPE_SYNCHRO)) and (Duel.IsExistingMatchingCard(s.eqfilter,tp,0,LOCATION_MZONE,1,nil) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 or (not tc:IsHasEffect(EFFECT_DIRECT_ATTACK) and Duel.IsAbleToEnterBP()) or Duel.IsAbleToEnterBP())
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	local eq,da,dam=Duel.IsExistingMatchingCard(s.eqfilter,tp,0,LOCATION_MZONE,1,nil) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0,not tc:IsHasEffect(EFFECT_DIRECT_ATTACK) and Duel.IsAbleToEnterBP(),Duel.IsAbleToEnterBP()
	local choice
	if eq and da and dam then choice=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))
	elseif eq and da then choice=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))+3
	elseif da and dam then choice=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))+5
	elseif eq and dam then choice=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,3))+7
	else return end
	if choice==0 or choice==3 or choice==7 then Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,1-tp,LOCATION_MZONE)
	elseif choice==2 or choice==6 or choice==8 then Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
	end
	e:SetLabelObject({tc,choice})
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c,tc,choice=e:GetHandler(),table.unpack(e:GetLabelObject())
	if not tc then return end
	if (choice==0 or choice==3 or choice==7) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		local ec=Duel.SelectMatchingCard(tp,s.eqfilter,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
		s.equipop(tc,e,tp,ec)
	elseif (choice==1 or choice==4 or choice==5) and not tc:IsHasEffect(EFFECT_DIRECT_ATTACK) and Duel.IsAbleToEnterBP() then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3205)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	elseif (choice==2 or choice==6 or choice==8) and Duel.IsAbleToEnterBP() then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_BATTLE_DESTROYING)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetCondition(aux.bdocon)
		e2:SetOperation(s.damop)
		tc:RegisterEffect(e2)
	else return end
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(1-tp,Duel.GetAttackTarget():GetTextAttack(),REASON_EFFECT)
end
function s.equipop(c,e,tp,tc)
	if not aux.EquipByEffectAndLimitRegister(c,e,tp,tc,nil,true) then return false end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(true)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	return true
end