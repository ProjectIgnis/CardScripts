--美しき妖魔の森
--Forest of the Beautiful Dark Queen
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Draw
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(s.condition)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	--Register cards sent
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_TO_GRAVE)
	e0:SetRange(LOCATION_FZONE)
	e0:SetLabelObject(e2)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
end
function s.filter(c)
	return c:IsSpellTrap() and c:IsReason(REASON_COST) and c:IsPreviousLocation(LOCATION_HAND|LOCATION_ONFIELD)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	if rp==tp and re and re:GetHandler():IsMonster() and eg:IsExists(s.filter,1,nil) then
		e:GetLabelObject():SetLabel(1)
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabel()==1
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.HasFlagEffect(tp,id) and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_CARD,0,id)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		Duel.Draw(tp,1,REASON_EFFECT)
	end
	e:SetLabel(0) --Reset flag
end