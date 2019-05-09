--Tinsight Assembly - Tribe Buster
--AlphaKretin
function c210310206.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0xf35),3,2)
	c:EnableReviveLimit()
	--repeat attack
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c210310206.atktg)
	e1:SetOperation(c210310206.atkop)
	c:RegisterEffect(e1)
	--return to extra
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17032740,0))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE) 
	e2:SetCountLimit(1)
	e2:SetTarget(c210310206.rettg)
	e2:SetOperation(c210310206.retop)
	c:RegisterEffect(e2)
	--no activation
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c210310206.accost)
	e3:SetOperation(c210310206.acop)
	c:RegisterEffect(e3)
end
function c210310206.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local rc=Duel.AnnounceRace(tp,1,RACE_ALL)
	e:SetLabel(rc)
end
function c210310206.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=e:GetLabel()
	local e1=Effect.CreateEffect(c)
	e1:SetLabel(rc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ATTACK_ALL)
	e1:SetValue(c210310206.atkfilter)
	c:RegisterEffect(e1)
	if c:IsRelateToEffect(e) 
		and c:CheckRemoveOverlayCard(tp,2,REASON_EFFECT) 
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(4034,4)) then
		if c:RemoveOverlayCard(tp,2,2,REASON_EFFECT) then
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetRange(LOCATION_MZONE)
			e2:SetTargetRange(0,LOCATION_MZONE)
			e2:SetCode(EFFECT_CHANGE_RACE)
			e2:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
			e2:SetValue(rc)
			c:RegisterEffect(e2)
		end
	end
end
function c210310206.atkfilter(e,c)
	return c:IsRace(e:GetLabel()) and c:IsFaceup()
end
function c210310206.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToExtra() end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
function c210310206.retfilter(c,e,tp)
	return c:GetReasonCard()==e:GetHandler() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c210310206.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if Duel.SendtoDeck(c,nil,2,REASON_EFFECT) then
		Duel.BreakEffect()
		if not Duel.IsPlayerAffectedByEffect(tp,59822133) 
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
			and Duel.IsExistingMatchingCard(c210310206.retfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
			and Duel.SelectYesNo(tp,aux.Stringid(4034,3)) then
			local g=Duel.GetMatchingGroup(c210310206.retfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
			for tc in aux.Next(g) do
				Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
				e1:SetValue(1)
				e1:SetReset(RESET_EVENT+0x1ff0000+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
				tc:RegisterEffect(e1)
				Duel.SpecialSummonComplete()
			end
		end
	end
end
function c210310206.accost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function c210310206.acop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(c210310206.aclimit)
	e1:SetCondition(c210310206.actcon)
	e1:SetReset(RESET_EVENT+0x1ff0000+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
	c:RegisterEffect(e1)
end
function c210310206.aclimit(e,re,tp)
	return not re:GetHandler():IsImmuneToEffect(e)
end
function c210310206.actcon(e)
	return Duel.GetAttacker()==e:GetHandler()
end
