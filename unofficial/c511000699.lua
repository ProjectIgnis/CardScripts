--Big Return
local s,id=GetID()
function s.initial_effect(c)
	--Allow a card's once-per-turn effects to be activated again
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		s[0]={}
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_ADJUST)
		ge2:SetCountLimit(1)
		ge2:SetOperation(s.clear)
		Duel.RegisterEffect(ge2,0)
	end)
end
function s.clear(e,tp,eg,ep,ev,re,r,rp)
	s[0]={}
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if re:IsHasProperty(EFFECT_FLAG_NO_TURN_RESET) then return end
	local _,ctmax,_,ctflag=re:GetCountLimit()
	local excluded=EFFECT_COUNT_CODE_OATH|EFFECT_COUNT_CODE_DUEL|EFFECT_COUNT_CODE_CHAIN
	if ctmax~=1 or (ctflag&excluded)~=0 then return end
	if rc:GetFlagEffect(id)==0 then
		s[0][rc]={}
		rc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,0)
	end
	for _,te in ipairs(s[0][rc]) do
		if te==re then return end
	end
	table.insert(s[0][rc],re)
end
function s.canrestore(te,tp)
	if te:IsDeleted() or te:CheckCountLimit(tp) then return false end
	for _,eff in ipairs({Duel.GetPlayerEffect(tp,EFFECT_CANNOT_ACTIVATE)}) do
		local value=eff:GetValue()
		if type(value)~="function" or value(eff,te,tp) then return false end
	end
	return true
end
function s.filter(c,tp)
	if c:GetFlagEffect(id)==0 or c:IsHasEffect(EFFECT_CANNOT_TRIGGER) then return false end
	for _,te in ipairs(s[0][c]) do
		if s.canrestore(te,tp) then return true end
	end
	return false
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and chkc~=e:GetHandler() and s.filter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_ONFIELD,0,1,e:GetHandler(),tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler(),tp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:GetFlagEffect(id)>0 then
		for _,te in ipairs(s[0][tc]) do
			if not te:IsDeleted() and not te:CheckCountLimit(tp) then
				local _,ctmax,ctcode,ctflag=te:GetCountLimit()
				if ctcode~=0 or ctflag~=0 then
					te:RestoreCountLimit(tp)
				else
					te:SetCountLimit(ctmax)
				end
			end
		end
	end
end
