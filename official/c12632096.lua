--超銀河眼の光波龍
--Neo Galaxy-Eyes Cipher Dragon
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure 3 Level 9 monsters
	Xyz.AddProcedure(c,nil,9,3)
	--Monsters you control cannot attack your opponent directly for the rest of this turn, except this card, also for each Material detached, take control of 1 opponent's face-up monster until the End Phase
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e) return e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,SET_CIPHER) end)
	e1:SetCost(Cost.Detach(1,s.ctcostmax,function(e,og) e:SetLabel(#og) end))
	e1:SetTarget(s.cttg)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_CIPHER}
s.listed_names={id}
function s.ctcostmax(e,tp)
	local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsAbleToChangeControler),tp,0,LOCATION_MZONE,nil)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_CONTROL)
	return math.min(ct,ft,3)
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,e:GetLabel(),0,0)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	--Monsters you control cannot attack your opponent directly for the rest of this turn, except this card
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) return fid~=c:GetFieldID() end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--For each Material detached, take control of 1 opponent's face-up monster until the End Phase
	local ct=math.min(e:GetLabel(),Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_CONTROL))
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsAbleToChangeControler),tp,0,LOCATION_MZONE,ct,ct,nil)
	Duel.GetControl(g,tp,PHASE_END,1)
	local og=Duel.GetOperatedGroup()
	if #og==0 then return end
	for tc in og:Iter() do
		if tc:IsNegatableMonster() then
			---Negate their effects
			tc:NegateEffects(c,RESET_PHASE|PHASE_END)
		end
		--Their ATK's become 4500
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(4500)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
		--Their names become "Neo Galaxy-Eyes Cipher Dragon"
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_CODE)
		e2:SetValue(id)
		e2:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e2)
	end
end
