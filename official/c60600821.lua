--春
--Spring
--scripted by Naim
local COUNTER_SEASON=0x214
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_SEASON)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Select any number of your Main Monster Zones to make them unusuable
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.countertg)
	e1:SetOperation(s.counterop)
	c:RegisterEffect(e1)
	--Monsters you control gain 400 ATK for each Season Counter on this card
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(function(e,c) return e:GetHandler():GetCounter(COUNTER_SEASON)*400 end)
	c:RegisterEffect(e2)
	--Place 1 Field Spell from your Deck that you can place a Season Counter on face-up on your field
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(function(e,tp) return Duel.IsTurnPlayer(1-tp) end)
	e3:SetTarget(s.pltg)
	e3:SetOperation(s.plop)
	c:RegisterEffect(e3)
end
s.counter_place_list={COUNTER_SEASON}
function s.countertg(e,tp,eg,ep,ev,re,r,rp,chk)
	local max_zones=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return max_zones>0 end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,max_zones,tp,COUNTER_SEASON)
end
function s.counterop(e,tp,eg,ep,ev,re,r,rp)
	local max_zones=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if max_zones<=0 then return end
	local ct=0
	local selected_zones=0
	repeat
		ct=ct+1
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLEZONE)
		local new_zone=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,selected_zones)
		selected_zones=selected_zones|new_zone
	until (ct>=max_zones or not Duel.SelectYesNo(tp,aux.Stringid(id,2)))
	local c=e:GetHandler()
	c:AddCounter(COUNTER_SEASON,ct)
	--Those zones cannot be used while this card is on the field
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetRange(LOCATION_FZONE)
	e1:SetOperation(function() return selected_zones end)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	c:RegisterEffect(e1)
end
function s.plfilter(c)
	return c:IsFieldSpell() and c:IsCanAddCounter(COUNTER_SEASON,1,false,LOCATION_ONFIELD) and not c:IsForbidden()
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,e:GetHandler():GetCounter(COUNTER_SEASON),tp,COUNTER_SEASON)
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local sc=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if not sc then return end
	local c=e:GetHandler()
	local ct=c:GetCounter(COUNTER_SEASON)
	local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	if fc then
		Duel.SendtoGrave(fc,REASON_RULE)
		Duel.BreakEffect()
	end
	if Duel.MoveToField(sc,tp,tp,LOCATION_FZONE,POS_FACEUP,true) then
		--Cannot activate its effects this turn
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3302)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		sc:RegisterEffect(e1)
		if ct>0 then
			sc:AddCounter(COUNTER_SEASON,ct)
		end
	end
end