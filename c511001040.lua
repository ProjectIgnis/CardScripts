--ドラゴン族・封印の壺
local s,id=GetID()
function s.initial_effect(c)
	--attach
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ADJUST)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(s.remop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_DELAY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.con)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	local e5=e2:Clone()
	e5:SetCode(EVENT_CHANGE_POS)
	c:RegisterEffect(e5)
	local e6=e2:Clone()
	e6:SetCode(EVENT_CHAIN_SOLVED)
	c:RegisterEffect(e6)
	--def
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_UPDATE_DEFENSE)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetValue(s.defval)
	c:RegisterEffect(e7)
end
function s.cfilter(c)
	return c:GetFlagEffect(id)>0
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler())
end
function s.filter(c,e,tid)
	if not c:IsRace(RACE_DRAGON) or c:IsFacedown() or c:IsImmuneToEffect(e) then return false end
	return c:GetFlagEffect(id)==0
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetFlagEffect(id)==0 then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD_DISABLE,0,0)
	end
	if not c:IsDisabled() and c:IsFaceup() then
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler(),e,e:GetHandler():GetFieldID())
		if #g>0 then
			Duel.Overlay(c,g)
		end
	else
		local og=c:GetOverlayGroup()
		if #og>0 then
			Duel.SendtoGrave(og,REASON_RULE)
		end
	end
end
function s.remop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsDisabled() and c:IsFacedown() then
		local og=c:GetOverlayGroup()
		if #og>0 then
			Duel.SendtoGrave(og,REASON_RULE)
		end
	end
end
function s.defval(e,c)
	local g=c:GetOverlayGroup()
	if not g or #g<=0 then return 0 end
	local def=0
	local tc=g:GetFirst()
	while tc do
		local tdef=tc:GetDefense()
		if tdef<0 then tdef=0 end
		def=def+tdef
		tc=g:GetNext()
	end
	return def
end
