--真紅眼の火竜
--Red-Eyes Mars Dragon
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Name becomes "Red-Eyes Black Dragon" in the hand or Graveyard
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e0:SetValue(CARD_REDEYES_B_DRAGON)
	c:RegisterEffect(e0)
	--Name change
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_REDEYES_B_DRAGON}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsCode(CARD_REDEYES_B_DRAGON) end
end
function s.filter(c)
	return c:IsMonster() and c:IsLegend() and c:IsType(TYPE_NORMAL)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	if Duel.DiscardDeck(tp,1,REASON_COST)<1 then return end
	--Effect
	--Name becomes "Red-Eyes Black Dragon"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetValue(CARD_REDEYES_B_DRAGON)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	c:RegisterEffect(e1)
	if Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil) and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
	--activate check
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHAINING)
	e2:SetReset(RESET_PHASE|PHASE_END)
	e2:SetOperation(s.aclimit)
	Duel.RegisterEffect(e2,tp)
	--activate limit
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetTargetRange(1,0)
	e3:SetReset(RESET_PHASE|PHASE_END)
	e3:SetCondition(s.econ)
	e3:SetValue(s.elimit)
	Duel.RegisterEffect(e3,tp)
end
function s.aclimit(e,tp,eg,ep,ev,re,r,rp)
	if ep~=tp or not re:GetHandler():IsCode(52684508) then return end
	local prevFlag=Duel.GetFlagEffect(e:GetHandlerPlayer(),id)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1,prevFlag+1)
end
function s.econ(e)
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)>=2
end
function s.elimit(e,te,tp)
	return te:GetHandler():IsCode(52684508)
end