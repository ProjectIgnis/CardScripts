--ミレニアム・アイズ・サクリファイス
--Millennium-Eyes Restrict
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials
	Fusion.AddProcMix(c,true,true,64631466,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT))
	--Equip 1 Effect Monster the opponent controls or in their GY to this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.eqcon)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	aux.AddEREquipLimit(c,nil,s.eqval,s.equipop,e1)
	--Gains ATK/DEF equal to the equipped monsters'
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function(e) return e:GetHandler():GetEquipGroup():FilterCount(s.eqgfilter,nil)>0 end)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(s.defval)
	c:RegisterEffect(e3)
	--Monsters with the equipped monsters' original name cannot attack
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(s.distg)
	c:RegisterEffect(e4)
	--Their effects on the field are negated
	local e5=e4:Clone()
	e5:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e5)
	--Their activated effects are negated
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_CHAIN_SOLVING)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(s.discon)
	e6:SetOperation(function(_,_,_,_,ev) Duel.NegateEffect(ev) end)
	c:RegisterEffect(e6)
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp,chk)
	return ep==1-tp and re:IsMonsterEffect()
end
function s.eqfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsAbleToChangeControler()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE|LOCATION_GRAVE) and chkc:IsControler(1-tp) and s.eqfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.eqfilter,tp,0,LOCATION_MZONE|LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.eqfilter,tp,0,LOCATION_MZONE|LOCATION_GRAVE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and s.eqfilter(tc) and tc:IsControler(1-tp) then
		s.equipop(c,e,tp,tc)
	end
end
function s.eqval(ec,c,tp)
	return ec:IsControler(1-tp) and ec:IsType(TYPE_EFFECT)
end
function s.equipop(c,e,tp,tc)
	c:EquipByEffectAndLimitRegister(e,tp,tc,id)
end
function s.eqgfilter(c)
	return c:IsFaceup() and c:HasFlagEffect(id)
end
function s.atkval(e,c)
	local g=c:GetEquipGroup():Match(s.eqgfilter,nil):Match(function(c) return c:GetTextAttack()>0 end,nil)
	return g:GetSum(Card.GetTextAttack)
end
function s.defval(e,c)
	local g=c:GetEquipGroup():Match(s.eqgfilter,nil):Match(function(c) return c:GetTextDefense()>0 end,nil)
	return g:GetSum(Card.GetTextDefense)
end
function s.distg(e,c)
	local eqg=e:GetHandler():GetEquipGroup():Match(s.eqgfilter,nil)
	return eqg:IsExists(Card.IsOriginalCodeRule,1,nil,c:GetOriginalCodeRule())
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local eqg=e:GetHandler():GetEquipGroup():Match(s.eqgfilter,nil)
	return re:IsMonsterEffect() and eqg:IsExists(Card.IsOriginalCodeRule,1,nil,re:GetHandler():GetOriginalCodeRule())
end