--Unfair Treaty
--scripted by Shad3 & GameMaster (GM)
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_LPCOST_REPLACE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.condition)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,2,nil) end
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,2,2,REASON_COST)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if re and tp==ep and re:GetActiveType()==TYPE_SPELL+TYPE_CONTINUOUS and e:GetHandler():GetFlagEffect(id)==0 then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT,0,0)
		local res=Duel.CheckLPCost(1-ep,ev)
		e:GetHandler():ResetFlagEffect(id)
		return res
	end
	return false
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT,0,0)
	Duel.Hint(HINT_CARD,0,c:GetOriginalCode())
	Duel.PayLPCost(1-ep,ev)
	c:ResetFlagEffect(id)
end
