--コスモ・プレデクター
--Cosmo Predictor
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Add card to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_SUMMON_TURN) and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==1
		and (not Duel.IsPlayerAffectedByEffect(tp,FLAG_NO_TRIBUTE)) and e:GetHandler():CanBeDoubleTribute(FLAG_DOUBLE_TRIB_GREYSTORM)
end
function s.thfilter(c)
	return c:IsLevel(8) and c:IsRace(RACE_GALAXY) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		--double tribute
		local c=e:GetHandler()
		c:AddDoubleTribute(id,s.otfilter,s.eftg,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,FLAG_DOUBLE_TRIB_GREYSTORM)
	end
end
function s.otfilter(c,tp)
	return c:IsDoubleTribute(FLAG_DOUBLE_TRIB_GREYSTORM) and (c:IsControler(tp) or c:IsFaceup())
end
function s.eftg(e,c)
	return c:IsCode(160432001) and c:IsLevelAbove(7) and c:IsSummonableCard()
end