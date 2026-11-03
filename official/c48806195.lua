--セリオンズ＂エンプレス＂アラシア
--Therion "Empress" Alasia
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--You can target 1 "Therion" monster or 1 Reptile monster in your GY; Special Summon this card from your hand, and if you do, equip that monster to this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.selfsptg)
	e1:SetOperation(s.selfspop)
	c:RegisterEffect(e1)
	aux.AddEREquipLimit(c,nil,function(ec,c,tp) return s.eqfilter(ec,tp) end,Card.EquipByEffectAndLimitRegister,e1)
	--You can discard 1 card, then target 1 "Therion" Monster Card in your Spell & Trap Zone; Special Summon it
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.Discard())
	e2:SetTarget(s.stzonesptg)
	e2:SetOperation(s.stzonespop)
	c:RegisterEffect(e2)
	--A "Therion" monster equipped with this card gains 700 ATK, also it can activate the 2nd effect listed above as if it were "Therion "Empress" Alasia"
	local e3a=Effect.CreateEffect(c)
	e3a:SetType(EFFECT_TYPE_EQUIP)
	e3a:SetCode(EFFECT_UPDATE_ATTACK)
	e3a:SetCondition(function(e)
		return e:GetHandler():GetEquipTarget():IsSetCard(SET_THERION)
	end)
	e3a:SetValue(700)
	c:RegisterEffect(e3a)
	local e3b=Effect.CreateEffect(c)
	e3b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3b:SetRange(LOCATION_SZONE)
	e3b:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3b:SetTarget(function(e,c)
		return c==e:GetHandler():GetEquipTarget() and c:IsSetCard(SET_THERION)
	end)
	e3b:SetLabelObject(e2)
	c:RegisterEffect(e3b)
end
s.listed_series={SET_THERION}
function s.eqfilter(c,tp)
	return (c:IsSetCard(SET_THERION) or c:IsRace(RACE_REPTILE)) and c:IsMonster() and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.eqfilter(chkc,tp) end
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,tp,0)
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
		and tc:IsRelateToEffect(e) then
		c:EquipByEffectAndLimitRegister(e,tp,tc)
	end
end
function s.stzonespfilter(c,e,tp)
	return c:IsSetCard(SET_THERION) and c:IsMonsterCard() and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.stzonesptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_STZONE) and s.stzonespfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.stzonespfilter,tp,LOCATION_STZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.stzonespfilter,tp,LOCATION_STZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
end
function s.stzonespop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end