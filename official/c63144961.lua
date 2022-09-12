--セイヴァー・アブソープション
--Majestic Absorption
--scripted by Rundas
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetLabel(0)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_STARDUST_DRAGON}
s.listed_series={0x3f}
function s.tgfilter(c,tp)
	local eq=Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	local datk=not c:IsHasEffect(EFFECT_DIRECT_ATTACK) and Duel.IsAbleToEnterBP()
	local dam=Duel.IsAbleToEnterBP()
	return c:IsFaceup() and c:IsCode(CARD_STARDUST_DRAGON) or (c:ListsCode(CARD_STARDUST_DRAGON) and c:IsType(TYPE_SYNCHRO))
		and (eq or datk or dam)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	local eq=Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	local datk=not tc:IsHasEffect(EFFECT_DIRECT_ATTACK) and Duel.IsAbleToEnterBP()
	local dam=Duel.IsAbleToEnterBP()
	local choice=-1
	if eq and datk and dam then choice=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))
	elseif eq and datk then choice=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))+3
	elseif datk and dam then choice=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))+5
	elseif eq and dam then choice=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,3))+7
	elseif eq then choice=Duel.SelectOption(tp,aux.Stringid(id,1))
	elseif datk then choice=Duel.SelectOption(tp,aux.Stringid(id,2))+1
	elseif dam then choice=Duel.SelectOption(tp,aux.Stringid(id,3))+2
	end
	if choice==0 or choice==3 or choice==7 then
		Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,1-tp,LOCATION_MZONE)
	end
	e:SetLabel(choice)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local choice=e:GetLabel()
	if not tc:IsRelateToEffect(e) then return end
	if (choice==0 or choice==3 or choice==7) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		--Equip
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local ec=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
		s.equipop(tc,e,tp,ec)
	elseif (choice==1 or choice==4 or choice==5) and not tc:IsHasEffect(EFFECT_DIRECT_ATTACK) then
		--Direct attack
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3205)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	elseif (choice==2 or choice==6 or choice==8) and Duel.IsAbleToEnterBP() then
		--Damage
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_BATTLE_DESTROYING)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetCondition(aux.bdocon)
		e2:SetOperation(s.damop)
		tc:RegisterEffect(e2)
	else return end
end
function s.equipop(c,e,tp,tc)
	if not c:EquipByEffectAndLimitRegister(e,tp,tc,nil,true) then return false end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(true)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	return true
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(1-tp,Duel.GetAttackTarget():GetTextAttack(),REASON_EFFECT)
end
