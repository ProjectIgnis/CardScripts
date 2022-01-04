-- セリオンズ“デューク”ユール
-- Therions' "Duke" Jule
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon self
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	aux.AddEREquipLimit(c,nil,s.eqval,aux.EquipByEffectAndLimitRegister,e1)
	-- "Therions" monsters protection
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(function(_,c) return c:IsSetCard(0x278) and c:IsFaceup() end)
	e2:SetCondition(s.indcon)
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- Equipped monster gains ATK
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetCondition(function(e) return e:GetHandler():GetEquipTarget():IsSetCard(0x278) end)
	e3:SetValue(700)
	c:RegisterEffect(e3)
	-- Equipped monster gains effect
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(function(e,c) return c==e:GetHandler():GetEquipTarget() and c:IsSetCard(0x278) end)
	e4:SetLabelObject(e2)
	c:RegisterEffect(e4)
end
s.listed_series={0x278}
function s.eqfilter(c)
	return c:IsMonster() and (c:IsSetCard(0x278) or c:IsRace(RACE_PSYCHIC))
end
function s.eqval(ec,c,tp)
	return ec:IsControler(tp) and s.eqfilter(ec)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.eqfilter(chkc) and not chkc:IsForbidden() end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingTarget(aux.AND(s.eqfilter,aux.NOT(Card.IsForbidden)),tp,LOCATION_GRAVE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,aux.AND(s.eqfilter,aux.NOT(Card.IsForbidden)),tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and tc:IsRelateToEffect(e)
		and tc:IsMonster() and not tc:IsForbidden() then
		aux.EquipByEffectAndLimitRegister(c,e,tp,tc)
	end
end
function s.indcon(e)
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsType,TYPE_EQUIP),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end