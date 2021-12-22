--サイバネット・コンフリクト
--Cynet Conflict
--Script by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x101}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsSetCard,0x101),tp,LOCATION_MZONE,0,1,nil)
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	if chk==0 then return Duel.IsPlayerCanRemove(tp,rc) and not (rc:IsMonster()
		and rc:IsLocation(LOCATION_GRAVE) and Duel.IsPlayerAffectedByEffect(rc:GetControler(),CARD_SPIRIT_ELIMINATION)) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if rc:IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,rc,1,0,rc:GetLocation())
	else
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,rc:GetPreviousLocation())
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ec=re:GetHandler()
	if Duel.NegateActivation(ev) and ec:IsRelateToEffect(re) then
		ec:CancelToGrave()
		Duel.Remove(ec,POS_FACEUP,REASON_EFFECT)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(0,1)
		e1:SetLabel(ec:GetOriginalCode())
		e1:SetValue(s.aclimit)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e2:SetDescription(aux.Stringid(id,1))
		e2:SetReset(RESET_PHASE+PHASE_END,2)
		e2:SetTargetRange(0,1)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.aclimit(e,re,tp)
	return re:GetHandler():GetOriginalCode()==e:GetLabel()
end
