--超重武者装留ガイア・ブースター
--Superheavy Samurai Soulgaia Booster
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Equip this card to a "Superheavy Samurai" monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND|LOCATION_MZONE)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_SUPERHEAVY_SAMURAI}
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp)
		 and c~=chkc and chkc:IsFaceup() and chkc:IsSetCard(SET_SUPERHEAVY_SAMURAI) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(aux.FaceupFilter(Card.IsSetCard,SET_SUPERHEAVY_SAMURAI),tp,LOCATION_MZONE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsSetCard,SET_SUPERHEAVY_SAMURAI),tp,LOCATION_MZONE,0,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if not (Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and tc:IsFaceup() and tc:IsRelateToEffect(e)
		and Duel.Equip(tp,c,tc,true)) then
		Duel.SendtoGrave(c,REASON_RULE)
	end
	--Equip limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetValue(function(_,c) return c==tc end)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	--Equipped monster is treated as a tuner
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_ADD_TYPE)
	e2:SetValue(TYPE_TUNER)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
	--Special Summon this card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e3)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(Card.IsSpellTrap,tp,LOCATION_GRAVE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end