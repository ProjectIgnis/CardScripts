--覇王烈竜オッドアイズ・レイジング・ドラゴン (Anime)
--Odd-Eyes Raging Dragon (Anime)
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Pendulum.AddProcedure(c,false)
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_DRAGON),7,2)
	--pendulum set
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.pctg)
	e1:SetOperation(s.pcop)
	c:RegisterEffect(e1)
	--material check
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	e2:SetLabelObject(e2)
	c:RegisterEffect(e2)
	--extra att
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetValue(1)
	--destroy
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCost(s.descost)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e5:SetRange(LOCATION_ONFIELD)
	e5:SetTargetRange(LOCATION_ONFIELD,0)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e5:SetCondition(s.efcon)
	e5:SetTarget(s.eftg)
	e5:SetLabelObject(e3)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetLabelObject(e4)
	c:RegisterEffect(e6,false,REGISTER_FLAG_DETACH_XMAT)
	--To Pendulum
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,2))
	e7:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e7:SetCode(EVENT_LEAVE_FIELD)
	e7:SetCondition(s.pencon)
	e7:SetTarget(s.pentg)
	e7:SetOperation(s.penop)
	c:RegisterEffect(e7)
end
function s.pcfilter(c)
	return c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp)
		and Duel.IsExistingMatchingCard(s.pcfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if not Duel.CheckPendulumZones(tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.pcfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetHandler():GetOverlayCount()
	if chk==0 then return ct>0 and e:GetHandler():CheckRemoveOverlayCard(tp,ct,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,ct,ct,REASON_COST)
end
function s.negfilter(c)
	return c:IsSpellTrap() and c:IsFaceup() and not c:IsDisabled()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.negfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.negfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
	end
	local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	local ct=Duel.Destroy(dg,REASON_EFFECT)
	if ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		Duel.BreakEffect()
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_UPDATE_ATTACK)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
		e4:SetValue(ct*200)
		c:RegisterEffect(e4)
	end
end
function s.matfilter(c,sc)
	return c:IsType(TYPE_XYZ,sc,SUMMON_TYPE_XYZ,sc:GetSummonPlayer()) and c:IsXyzLevel(sc,7)
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(s.matfilter,1,nil,c) then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD_DISABLE-RESET_TOFIELD,0,1)
	end
end
function s.efcon(e)
	return e:GetHandler():IsXyzSummoned() and e:GetHandler():GetFlagEffect(id)>0
end
function s.eftg(e,c)
	return c==e:GetHandler()
end
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP) and e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	if Duel.Destroy(g,REASON_EFFECT)~=0 and e:GetHandler():IsRelateToEffect(e) then
		Duel.MoveToField(e:GetHandler(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end