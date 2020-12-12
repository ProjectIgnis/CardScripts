--驚楽園の大使 <Bufo>
--Amazement Ambassador <Bufo>
--Scripted by Eerie Code

local s,id=GetID()
function s.initial_effect(c)
	--equip
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.eqtg1)
	e1:SetOperation(s.eqop1)
	c:RegisterEffect(e1)
	--equip change
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.eqtg2)
	e2:SetOperation(s.eqop2)
	c:RegisterEffect(e2)
end
s.listed_series={0x25e,0x25d}
function s.eqfilter1(c)
	return c:IsSetCard(0x25e) and c:IsType(TYPE_TRAP)
end
function s.eqtg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and
		       Duel.IsExistingTarget(s.eqfilter1,tp,LOCATION_GRAVE,0,1,nil) and
		       Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g1=Duel.SelectTarget(tp,s.eqfilter1,tp,LOCATION_GRAVE,0,1,1,nil)
	local tc=g1:GetFirst()
	e:SetLabelObject(tc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g2=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tc,1,0,0)
end
function s.eqop1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local ec=e:GetLabelObject()
	local g=Duel.GetTargetCards(e)
	if #g<2 then return end
	local tc=g:GetFirst()
	if tc==ec then tc=g:GetNext() end
	if ec:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Equip(tp,ec,tc)
	end
end
function s.eqsfilter(c)
	return c:IsSetCard(0x25e) and c:IsType(TYPE_TRAP) and c:GetEquipTarget() and
	       Duel.IsExistingTarget(s.eqmfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,c:GetEquipTarget(),tp)
end
function s.eqmfilter(c,tp)
	return c:IsFaceup() and (c:IsSetCard(0x25d) or (not c:IsControler(tp)))
end
function s.eqtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.eqsfilter,tp,LOCATION_SZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.eqsfilter,tp,LOCATION_SZONE,0,1,1,nil)
end
function s.eqop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetTargetCards(e):GetFirst()
	if not tc then return end
	local mc=Duel.SelectMatchingCard(tp,s.eqmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,tc:GetEquipTarget(),tp):GetFirst()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and
	   mc:IsFaceup() then Duel.Equip(tp,tc,mc) end
end
