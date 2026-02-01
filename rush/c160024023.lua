--サイボーグ・ドルフィン
--Mech Dolphin
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Return 1 card on the field to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND|CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FISH) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_RITUAL) and c:IsLevelBelow(7) 
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.thfilter(c)
	return c:IsAbleToHand() and c:IsNotMaximumModeSide()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #tc>0 then
		tc=tc:AddMaximumCheck()
		Duel.HintSelection(tc)
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		--Prevent non-fish from attacking
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_OATH)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(s.ftarget)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.ftarget(e,c)
	return not c:IsRace(RACE_FISH)
end