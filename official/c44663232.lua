--異怪の妖精 エルフォビア
--Ghost Fairy Elfobia
local s,id=GetID()
function s.initial_effect(c)
	--Activate limit
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and not c:IsPublic()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
	e:SetLabel(g:GetFirst():GetLevel())
	Duel.ShuffleHand(tp)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,1)
	e1:SetLabel(e:GetLabel()+1)
	e1:SetReset(RESET_PHASE|PHASE_MAIN1|RESET_OPPO_TURN)
	e1:SetValue(s.val)
	Duel.RegisterEffect(e1,tp)
end
function s.val(e,re,tp)
	return re:IsMonsterEffect() and re:GetHandler():IsLevelAbove(e:GetLabel())
end