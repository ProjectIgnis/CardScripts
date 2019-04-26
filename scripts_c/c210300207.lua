--Chitterite Angel
function c210300207.initial_effect(c)
	c:EnableReviveLimit()
	--atk,def
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(function(e,c) if not c:GetEquipGroup() or c:GetEquipGroup():FilterCount(function(c)return c:GetOriginalType()&TYPE_MONSTER~=0 end,nil)==0 then
			return 0
		else
			return c:GetEquipGroup():GetSum(Card.GetAttack)
		end
	end)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e2)
	--indes
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--equip
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(210300207,0))
	e4:SetCategory(CATEGORY_EQUIP)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,210300207+EFFECT_COUNT_CODE_OATH)
	e4:SetCondition(c210300207.eqcon)
	e4:SetTarget(c210300207.eqtg)
	e4:SetOperation(c210300207.eqop)
	c:RegisterEffect(e4)
end
function c210300207.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return c210300207.can_equip_monster(e:GetHandler())
end
function c210300207.eqfilter(c)
	return c:GetFlagEffect(210300207)~=0
end
function c210300207.can_equip_monster(c)
	local g=c:GetEquipGroup():Filter(c210300207.eqfilter,nil)
	return g:GetCount()==0
end
function c210300207.filter(c,atk)
	return c:IsAbleToChangeControler() and c:GetAttack()>atk
end
function c210300207.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local atk=Duel.GetFieldGroup(tp,LOCATION_MZONE,0):Filter(Card.IsFaceup,nil):GetSum(Card.GetAttack)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c210300207.filter(c,atk) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(c210300207.filter,tp,0,LOCATION_MZONE,1,nil,atk) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,c210300207.filter,tp,0,LOCATION_MZONE,1,1,nil,atk)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function c210300207.eqlimit(e,c)
	return e:GetOwner()==c
end
function c210300207.equip_monster(c,tp,tc)
	if not Duel.Equip(tp,tc,c,false) then return end
	--Add Equip limit
	tc:RegisterFlagEffect(210300207,RESET_EVENT+RESETS_STANDARD,0,0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c210300207.eqlimit)
	tc:RegisterEffect(e1)
	--substitute
	local e2=Effect.CreateEffect(c)
 	e2:SetType(EFFECT_TYPE_EQUIP)
 	e2:SetCode(EFFECT_DESTROY_SUBSTITUTE)
 	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
 	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
 	e2:SetValue(c210300207.repval)
 	tc:RegisterEffect(e2)
end
function c210300207.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and tc:IsControler(1-tp) then
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			c210300207.equip_monster(c,tp,tc)
		else Duel.SendtoGrave(tc,REASON_EFFECT) end
	end
end
