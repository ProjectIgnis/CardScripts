--光の封札剣 (Anime)
--Lightforce Sword (Anime)
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,1,nil):GetFirst()
	if tc and Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_REMOVED)
		and tc:IsFacedown() and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		local c=e:GetHandler()
		local tid=Duel.GetTurnCount()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetRange(LOCATION_REMOVED)
		e1:SetCountLimit(1)
		e1:SetLabel(0)
		e1:SetCondition(function()
			return Duel.IsTurnPlayer(1-tp) and Duel.GetTurnCount()~=tid
		end)
		e1:SetOperation(s.thop)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_STANDBY,8)
		tc:RegisterEffect(e1)
		if Duel.IsTurnPlayer(1-tp) then s.thop(e1) end
		local descnum=tp==c:GetOwner() and 0 or 1
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,descnum))
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(1082946)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
		e2:SetLabelObject(e1)
		e2:SetOwnerPlayer(tp)
		e2:SetOperation(s.reset)
		e2:SetReset(RESET_PHASE|PHASE_STANDBY|RESET_OPPO_TURN,4)
		c:RegisterEffect(e2)
	end
end
function s.reset(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetLabelObject() then e:Reset() return end
	s.thop(e:GetLabelObject(),tp,eg,ep,ev,e,r,rp)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()+1
	e:GetOwner():SetTurnCounter(ct)
	e:SetLabel(ct)
	if ct==4 then
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
		if re then re:Reset() end
	end
end
