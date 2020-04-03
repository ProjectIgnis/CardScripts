--Backup Gardna
local s,id=GetID()
function s.initial_effect(c)
	--Redirect Equip
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	--Negate attacks
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetCost(s.indcost)
	e2:SetOperation(s.indop)
	c:RegisterEffect(e2)
end
function s.filter1(c,tp)
	return c:IsFaceup() and c:GetEquipTarget()
		and Duel.IsExistingTarget(s.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,c:GetEquipTarget(),c)
end
function s.filter2(c,eqc)
	return c:IsFaceup() and eqc:CheckEquipTarget(c)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_SZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g1=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_SZONE,0,1,1,nil,tp)
	local eqc=g1:GetFirst()
	e:SetLabelObject(eqc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g2=Duel.SelectTarget(tp,s.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,eqc:GetEquipTarget(),eqc)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g1,1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local eqc=e:GetLabelObject()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==eqc then tc=g:GetNext() end
	if not eqc:IsRelateToEffect(e) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		Duel.SendtoGrave(eqc,REASON_EFFECT)
		return
	end
	Duel.Equip(tp,eqc,tc)
end
function s.indcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function s.indop(e,tp,eg,ep,ev,re,r,rp)
Duel.NegateAttack()
end
