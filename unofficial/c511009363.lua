--Spirit Reactor
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	--indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(s.indcon)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(s.indct)
	c:RegisterEffect(e2)
	-- copy scale
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(94585852,0))
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e8:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e8:SetCode(511002005)
	e8:SetRange(LOCATION_PZONE)
	e8:SetTarget(s.sctg)
	e8:SetOperation(s.scop)
	c:RegisterEffect(e8)
	aux.GlobalCheck(s,function()
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_ADJUST)
		ge2:SetOperation(s.checkop)
		Duel.RegisterEffect(ge2,0)
	end)
end
function s.val(e,c)
	return Duel.GetMatchingGroupCount(s.filter,c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,nil)*500
end
function s.filter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH+ATTRIBUTE_WATER+ATTRIBUTE_FIRE+ATTRIBUTE_WIND) and c:IsFaceup()
end
function s.indcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.indct(e,re,r,rp)
	if r&REASON_BATTLE+REASON_EFFECT~=0 then
		return 1
	else return 0 end
end
function s.cfilter(c)
	local seq=c:GetSequence()
	return c:GetFlagEffect(511002005+seq)==0 and (not c:IsPreviousLocation(LOCATION_PZONE) or c:GetPreviousSequence()~=seq)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tot=Duel.IsDuelType(DUEL_SEPARATE_PZONE) and 13 or 4
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_PZONE,LOCATION_PZONE,nil)
	local tc=g:GetFirst()
	while tc do
		tc:ResetFlagEffect(511002005+tot-tc:GetSequence())
		Duel.RaiseSingleEvent(tc,511002005,e,0,tp,tp,0)
		tc:RegisterFlagEffect(511002005+tc:GetSequence(),RESET_EVENT+RESETS_STANDARD,0,1)
		tc=g:GetNext()
	end
end
function s.scfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc~=e:GetHandler() and chkc:IsOnField() and s.scfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.scfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.scfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
end
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LSCALE)
		e1:SetValue(tc:GetLeftScale())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_RSCALE)
		e2:SetValue(tc:GetRightScale())
		c:RegisterEffect(e2)
	end
end
