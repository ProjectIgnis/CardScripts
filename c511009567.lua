--Raidraptor - Final Fortress Falcon
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_WINGEDBEAST),12,3)
	c:EnableReviveLimit()	
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33334269,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
	--multi atk
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(56532353,0))
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.atkcon)
	e4:SetCost(s.atkcost)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0xba)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_RETURN)
	end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	return a and a:IsRelateToBattle() and a:IsSetCard(0xba) and a:IsControler(tp)
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	local g=e:GetHandler():GetOverlayGroup()
	Duel.SendtoGrave(g,REASON_COST)
end
function s.cfilter(c)
	return c:IsSetCard(0xba) and c:IsType(TYPE_XYZ) and c:IsAbleToRemoveAsCost()
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local a=Duel.GetAttacker()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_DAMAGE_STEP_END)
		e1:SetCondition(s.atcon)
		e1:SetCost(s.atcost)
		e1:SetOperation(s.atop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		a:RegisterEffect(e1)
		if Duel.SelectYesNo(tp,94) and a:CanChainAttack(0) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) then
			local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
			if Duel.Remove(g,POS_FACEUP,REASON_COST) then
				Duel.ChainAttack()
			end
		end
end
function s.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.GetAttacker()==c and c:CanChainAttack(0)
end
function s.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.ChainAttack()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
	Duel.GetAttacker():RegisterEffect(e1)
end
