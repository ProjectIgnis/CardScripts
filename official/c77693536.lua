--フルメタルフォーゼ・アルカエスト
--Fullmetalfoes Alkahest
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_METALFOES),aux.FilterBoolFunctionEx(Card.IsType,TYPE_NORMAL))
	--Must be Fusion Summoned
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)
	--Equip 1 Effect Monster on the field to this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e,tp) return Duel.IsTurnPlayer(1-tp) end)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	aux.AddEREquipLimit(c,nil,aux.FilterBoolFunction(Card.IsType,TYPE_EFFECT),function(c,e,tp,tc) c:EquipByEffectAndLimitRegister(e,tp,tc,id,true) end,e1)
	--Gains DEF equal to the combine original ATK of the monsters equipped to it by its effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.defval)
	c:RegisterEffect(e2)
	--Can use monsters you control equipped to this card you control as material for the Fusion Summon of a "Metalfoes" Fusion Monster
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_SZONE,0)
	e3:SetTarget(function(e,c) return c:GetEquipTarget()==e:GetHandler() and c:IsOriginalType(TYPE_MONSTER) end)
	e3:SetValue(function(e,c) return c and c:IsSetCard(SET_METALFOES) and c:IsControler(e:GetHandlerPlayer()) end)
	c:RegisterEffect(e3)
end
s.listed_series={SET_METALFOES}
s.material_setcode=SET_METALFOES
function s.eqfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and (c:IsControler(tp) or c:IsAbleToChangeControler())
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.eqfilter(chkc,tp) and chkc~=c end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c,tp)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,tp,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_EFFECT) then
		c:EquipByEffectAndLimitRegister(e,tp,tc,id,true)
	end
end
function s.defvalfilter(c)
	return c:HasFlagEffect(id) and c:GetTextAttack()>=0
end
function s.defval(e,c)
	return e:GetHandler():GetEquipGroup():Filter(s.defvalfilter,nil):GetSum(Card.GetTextAttack)
end