--双焔魔の飛鼠
--Bat of the Twin Blaze Fiends
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Set
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={160215036,160022062}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_SUMMON_TURN)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
end
function s.sfilter(c)
	return c:IsCode(160215036,160022062) and c:IsSSetable()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_GRAVE,0,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	if Duel.SendtoGrave(c,REASON_COST)<1 then return end
	--Effect
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local sg=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_GRAVE,0,nil)
	local tg=aux.SelectUnselectGroup(sg,1,tp,1,math.min(ft,2),s.rescon,1,tp)
	Duel.SSet(tp,tg)
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsCode,nil,160215036)<2 and sg:FilterCount(Card.IsCode,nil,160022062)<2
end