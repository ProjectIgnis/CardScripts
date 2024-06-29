--ベリーフレッシュ・ハピネス・ハーベスト
--Berry Fresh Happiness Harvest
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Gain ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_SUMMON_TURN|STATUS_SPSUMMON_TURN)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,e:GetHandler()) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,2,c)
	local ct=Duel.SendtoGrave(g,REASON_COST)
	if ct<1 then return end
	--Effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
	e1:SetReset(RESETS_STANDARD_PHASE_END,2)
	e1:SetValue(ct*1500)
	c:RegisterEffect(e1)
	if Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_GRAVE,0,5,nil,RACE_AQUA) then
		--Cannot be destroyed by opponent's spell/trap
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(3013)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetValue(s.indval)
		e2:SetReset(RESETS_STANDARD_PHASE_END,2)
		c:RegisterEffect(e2)
	end
end
function s.indval(e,re,rp)
	return (re:IsTrapEffect() or re:IsSpellEffect()) and re:GetOwnerPlayer()~=e:GetOwnerPlayer()
end