--エターナル・リバース
--Eternal Reverse
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--Once per turn, you can Set 1 Spell/Trap Card on your opponent's side of the field face-down. That Set card cannot be activated for the rest of this turn.
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	--If the equipped monster would be destroyed by battle, you can send this card to the GY instead
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetTarget(s.replacetg)
	c:RegisterEffect(e2)
end
function s.setfilter(c)
	return c:IsFaceup() and c:IsSpellTrap() and c:IsCanTurnSet() and not c:IsType(TYPE_PENDULUM)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,0,LOCATION_ONFIELD,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.setfilter,tp,0,LOCATION_ONFIELD,nil)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectMatchingCard(tp,s.setfilter,tp,0,LOCATION_ONFIELD,1,1,nil):GetFirst()
	Duel.HintSelection(tc)
	if tc and tc:IsFaceup() then
		tc:CancelToGrave()
		Duel.ChangePosition(tc,POS_FACEDOWN)
		tc:SetStatus(STATUS_SET_TURN,false)
		Duel.RaiseEvent(tc,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end
function s.replacetg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if chk==0 then return ec:IsReason(REASON_BATTLE) and not ec:IsReason(REASON_REPLACE)
		and c:IsAbleToGrave() and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		Duel.SendtoGrave(c,REASON_EFFECT)
		return true
	else return false end
end
