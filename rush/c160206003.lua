--グレートホーン・マンモス
--Great-Tusked Mammoth
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Prevent activations
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e)return e:GetHandler():IsStatus(STATUS_SUMMON_TURN)end)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	if Duel.DiscardDeck(tp,1,REASON_COST)==0 then return end
	--Effect
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetValue(s.aclimit)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
	e1:SetTargetRange(1,1)
	c:RegisterEffect(e1)
end
function s.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return re:IsMonsterEffect() and rc:IsOnField() and rc:IsFaceup() and rc:IsLevelBelow(4)
end