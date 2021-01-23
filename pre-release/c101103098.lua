--War Rock Ordeal
--scripted by Rundas
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	c:EnableCounterPermit(0x205)
	--place counters on activation
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)
	--remove counter + draw
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_COUNTER+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.dcon)
	e2:SetTarget(s.dtg)
	e2:SetOperation(s.dop)
	c:RegisterEffect(e2)
	--to GY when last counter is removed
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_REMOVE_COUNTER)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.tgcon)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
end
s.listed_names={id}
s.listed_series={0x25c}
s.counter_place_list={0x205}
--place counters on activation
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	e:GetHandler():AddCounter(0x205,3)
end
--remove counter + draw
function s.dcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local rc=tc:GetReasonCard()
	return #eg==1 and rc:IsControler(tp) and tc:IsType(TYPE_MONSTER) and tc:IsReason(REASON_BATTLE) and tc:IsLocation(LOCATION_GRAVE) and rc:IsSetCard(0x25c)
end
function s.dtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and e:GetHandler():IsCanRemoveCounter(tp,0x205,1,REASON_EFFECT) end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,e:GetHandler(),1,tp,LOCATION_SZONE)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,1,tp,LOCATION_DECK)
end
function s.dop(e,tp,eg,ep,ev,re,r,rp)
	--remove counter returns void so there is no suitable check for "and if you do"
	e:GetHandler():RemoveCounter(tp,0x205,1,REASON_EFFECT)
	Duel.Draw(tp,1,REASON_EFFECT)
end
--to GY when last counter is removed
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x205)==0
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGrave() end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,tp,LOCATION_SZONE)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
end
