--聖蔓の略奪
--Sunvine Plunder
--Scripted by Playmaker 772211, fixed by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Take control of a Spell
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Return the controled card to its owner when this card leaves the field
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetOperation(s.checkop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetOperation(s.ctrlop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	--Destroy this card when the controlled card leaves the field
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(s.descon)
	e4:SetOperation(s.desop)
	e4:SetLabelObject(e1)
	c:RegisterEffect(e4)
end
s.listed_series={0x1157}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	Duel.PayLPCost(tp,800)
end
function s.tgfilter(c,e,tp)
	if not (c:IsFaceup() and c:IsSpell()) then return false end
	local loc=c:GetLocation()
	if c:IsType(TYPE_FIELD) then
		return true
	elseif loc==LOCATION_MZONE then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	elseif loc==LOCATION_SZONE then
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if e:GetHandler():IsLocation(LOCATION_HAND) then ft=ft-1 end
		return ft>0
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:GetHandler():IsLocation(LOCATION_HAND) then ft=ft-1 end
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsSpell() and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,0,LOCATION_ONFIELD,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,0,LOCATION_ONFIELD,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) then return end
	local loc=tc:GetLocation()
	if tc:IsType(TYPE_FIELD) then
		loc=LOCATION_FZONE
	end
	if tc then
		if loc==LOCATION_MZONE then
			Duel.GetControl(tc,tp)
		else
			if loc==LOCATION_FZONE or Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
				local ec
				if tc:IsType(TYPE_EQUIP) then
					ec=tc:GetEquipTarget()
				end
				if not tc:IsImmuneToEffect(e) then
					Duel.MoveToField(tc,tp,tp,loc,POS_FACEUP,true)
					if ec then
						Debug.PreEquip(tc,ec)
					end
				end
			else
				Duel.SendtoGrave(tc,REASON_RULE)
			end
		end
		if not tc:IsLocation(LOCATION_ONFIELD) or not tc:IsControler(tp) then return end
		--Cannot be targeted by opponent's card effects
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetCondition(s.tgocon)
		e1:SetValue(aux.tgoval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		c:RegisterEffect(e2)
		e:SetLabelObject(tc)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end
function s.cfilter(c)
	return c:IsSetCard(SET_SUNAVALON) and c:IsMonster() and c:IsFaceup()
end
function s.tgocon(e)
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsDisabled() then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
function s.ctrlop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetLabel()~=0 then return end
	local tc=e:GetLabelObject():GetLabelObject():GetLabelObject()
	if not tc or not tc:IsLocation(LOCATION_ONFIELD) or tc:GetFlagEffect(id)==0 then return end
	local loc=tc:GetLocation()
	if tc:IsType(TYPE_FIELD) then
		loc=LOCATION_FZONE
	end
	if loc==LOCATION_MZONE then
		Duel.GetControl(tc,1-tp)
	else
		if loc==LOCATION_FZONE or Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0 then
			local ec
			if tc:IsType(TYPE_EQUIP) then
				ec=tc:GetEquipTarget()
			end
			Duel.MoveToField(tc,1-tp,1-tp,loc,POS_FACEUP,true)
			if ec then
				Debug.PreEquip(tc,ec)
			end
		else
			Duel.SendtoGrave(tc,REASON_RULE)
		end
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject():GetLabelObject()
	return tc and eg:IsContains(tc)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end