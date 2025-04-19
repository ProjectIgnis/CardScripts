--ソルジャー・リボルト
--Soldier Revolt
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_TOGRAVE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={79853073,67532912,75559356}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,79853073),tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,67532912),tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,75559356),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_BATTLE_PHASE)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_HAND,1,nil)
		and Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	local tg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	local dg=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,tg,#tg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,#dg,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if Duel.SendtoGrave(tg,REASON_EFFECT)>0 and tg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)>0 then
		Duel.Destroy(Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD),REASON_EFFECT)
	end
end