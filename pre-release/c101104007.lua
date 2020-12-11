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
	return c:IsSetCard(0x25e) and c:IsType(TYPE_TRAP) and c:GetEquipTarget()
		and Duel.IsExistingTarget(s.eqfilter2,0,0,LOCATION_MZONE,1,c:GetEquipTarget(),c)
end
function s.eqfilter2(c,ec)
	return c:IsFaceup() and ec:CheckEquipTarget(c)
end
function s.eqtg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 
		and Duel.IsExistingTarget(s.eqfilter1,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g1=Duel.SelectTarget(tp,s.eqfilter1,tp,LOCATION_GRAVE,0,1,1,nil)
	local tc=g1:GetFirst()
	e:SetLabelObject(tc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g2=Duel.SelectTarget(tp,s.eqfilter2,tp,0,LOCATION_MZONE,1,1,tc:GetEquipTarget(),tc)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tc,1,0,0)
end
function s.eqop1(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetLabelObject()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==ec then tc=g:GetNext() end
	if ec:IsRelateToEffect(e) and ec:CheckEquipTarget(tc) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		Duel.Equip(tp,ec,tc)
	end
end
function s.eqfilter3(c)
	return c:IsSetCard(0x25e) and c:IsType(TYPE_TRAP) and c:GetEquipTarget()
		and Duel.IsExistingTarget(s.eqfilter4,0,LOCATION_MZONE,LOCATION_MZONE,1,c:GetEquipTarget(),c,tp)
end
function s.eqfilter4(c,ec,tp)
	return c:IsFaceup() and (c:IsSetCard(0x25d) or not c:IsControler(tp)) and ec:CheckEquipTarget(c)
end
function s.eqtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.eqfilter3,tp,LOCATION_SZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g1=Duel.SelectTarget(tp,s.eqfilter3,tp,LOCATION_SZONE,0,1,1,nil)
	local tc=g1:GetFirst()
	e:SetLabelObject(tc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g2=Duel.SelectTarget(tp,s.eqfilter4,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,tc:GetEquipTarget(),tc,tp)
end
function s.eqop2(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetLabelObject()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==ec then tc=g:GetNext() end
	if ec:IsFaceup() and ec:IsRelateToEffect(e) and ec:CheckEquipTarget(tc) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		Duel.Equip(tp,ec,tc)
	end
end
