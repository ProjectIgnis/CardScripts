--ペンデュラム・ペンダント
--Pendulum Pendant
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Place 1 Pendulum monster in the Pendulum Zone
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_LIMIT_ZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetValue(s.zones)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Reduce a Pendulum Scale by 1
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.scltg)
	e2:SetOperation(s.sclop)
	c:RegisterEffect(e2)
end
function s.zones(e,tp,eg,ep,ev,re,r,rp)
	local zone=0xff --all Spell/Trap zones
	if Duel.IsDuelType(DUEL_SEPARATE_PZONE) then return zone end
	local p0=Duel.CheckLocation(tp,LOCATION_PZONE,0)
	local p1=Duel.CheckLocation(tp,LOCATION_PZONE,1)
	if p0==p1 then return zone end
	if p0 then zone=zone-0x1 end --remove the left most S/T zone
	if p1 then zone=zone-0x10 end --remove the right most S/T zone
	return zone
end
function s.costfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsAbleToRemoveAsCost()
end
function s.pendfilter(c)
	return c:IsType(TYPE_PENDULUM) and (c:IsFaceup() or c:IsLocation(LOCATION_DECK)) and not c:IsForbidden()
end
function s.rescon(pg)
	return function(sg,e,tp,mg)
		return #sg==5 and pg:IsExists(aux.TRUE,1,sg)
	end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_EXTRA,0,nil)
	local pg=Duel.GetMatchingGroup(s.pendfilter,tp,LOCATION_EXTRA|LOCATION_DECK,0,nil)
	if chk==0 then return #g>=5 and aux.SelectUnselectGroup(g,e,tp,5,5,s.rescon(pg),0) end
	local rg=aux.SelectUnselectGroup(g,e,tp,5,5,s.rescon(pg),1,tp,HINTMSG_REMOVE)
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp)
		and Duel.IsExistingMatchingCard(s.pendfilter,tp,LOCATION_EXTRA|LOCATION_DECK,0,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.pendfilter,tp,LOCATION_EXTRA|LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
function s.sclfilter(c)
	return c:GetScale()>0
end
function s.scltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) end
	if chk==0 then return Duel.IsExistingTarget(s.sclfilter,tp,LOCATION_PZONE,LOCATION_PZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.sclfilter,tp,LOCATION_PZONE,LOCATION_PZONE,1,1,nil)
end
function s.sclop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:GetScale()>0 then
		--Reduce its scale by 1
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_LSCALE)
		e1:SetValue(-1)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_RSCALE)
		tc:RegisterEffect(e2)
	end
end