CARD_CLOCK_LIZARD = 51476410
function Auxiliary.addLizardCheck(c)
	--lizard check
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(CARD_CLOCK_LIZARD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	return e1
end
--lizard check with a reset
function Auxiliary.createTempLizardCheck(c,filter,reset,tRange,tRange2,resetcount)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(CARD_CLOCK_LIZARD)
	e1:SetTargetRange(tRange or 0xff,tRange2 or 0)
	e1:SetReset(reset or (RESET_PHASE|PHASE_END),resetcount)
	e1:SetTarget(filter or aux.TRUE)
	e1:SetValue(1)
	return e1
end
function Auxiliary.addTempLizardCheck(c,filter,reset,tRange,tRange2,resetcount)
	local e1=aux.createTempLizardCheck(c,filter,reset,tRange,tRange2,resetcount)
	Duel.RegisterEffect(e1,tp)
	return e1
end
--lizard check for cards like Yang Zing Creation
function Auxiliary.createContinuousLizardCheck(c,location,filter,tRange,tRange2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(CARD_CLOCK_LIZARD)
	e1:SetTargetRange(tRange or 0xff,tRange2 or 0)
	e1:SetRange(location)
	e1:SetTarget(filter or aux.TRUE)
	e1:SetValue(1)
	return e1
end
function Auxiliary.addContinuousLizardCheck(c,location,filter,tRange,tRange2)
	local e1=aux.createContinuousLizardCheck(c,location,filter,tRange,tRange2)
	c:RegisterEffect(e1)
	return e1
end
function Fusion.AddContactProc(c,group,op,sumcon,condition,sumtype,desc,cannotBeLizard)
	local mt=c.__index
	local t={}
	if mt.contactfus then
		t=mt.contactfus
	end
	t[c]=true
	mt.contactfus=t
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	if not desc then
		e1:SetDescription(2)
	else
		e1:SetDescription(desc)
	end
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	if sumtype then
		e1:SetValue(sumtype)
	end
	e1:SetCondition(Fusion.ContactCon(group,condition))
	e1:SetTarget(Fusion.ContactTg(group))
	e1:SetOperation(Fusion.ContactOp(op))
	c:RegisterEffect(e1)
	if sumcon then
		--spsummon condition
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e2:SetCode(EFFECT_SPSUMMON_CONDITION)
		if type(sumcon)=='function' then
			e2:SetValue(sumcon)
		end
		c:RegisterEffect(e2)
	end
	--lizard check
	if cannotBeLizard~=false then
		Auxiliary.addLizardCheck(c)
	end
end