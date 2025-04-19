--NO12 エーテリック・まへす
--New Orders 12 Etheric Mahes
local s,id=GetID()
function s.initial_effect(c)
	--Xyz summon
	Xyz.AddProcedure(c,nil,12,2)
	c:EnableReviveLimit()
	--Special Summon attached monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Destroy
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
function s.filter(c,e,tp)
	return not c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft<=0 then return false end
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
		local g=e:GetHandler():GetOverlayGroup()
		local count=#g
		if count==0 or count>ft then return false end
		return not g:IsExists(s.filter,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_OVERLAY)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return false end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local c=e:GetHandler()
	local g=c:GetOverlayGroup()
	local count=#g
	if count==0 or count>ft then return end
	if g:IsExists(s.filter,1,nil,e,tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_INITIAL+EFFECT_FLAG_REPEAT)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_EVENT+(RESETS_STANDARD&(~RESET_TEMP_REMOVE))+RESET_PHASE+PHASE_END)
	e1:SetCondition(s.retcon)
	e1:SetOperation(s.retop)
	c:RegisterEffect(e1)
	for tc in g:Iter() do
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		c:SetCardTarget(tc)
	end
	Duel.SpecialSummonComplete()
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetCardTarget():Filter(Card.IsLocation,nil,LOCATION_MZONE)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCardTargetCount()>0
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetCardTarget():Filter(Card.IsLocation,nil,LOCATION_MZONE)
	if #g>0 then
		Duel.Overlay(c,g)
	end
end