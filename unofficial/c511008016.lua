--Court Battle
--Scripted by Snrk
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,1,id)
	--tokens
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.toktg)
	e1:SetOperation(s.tokop)
	c:RegisterEffect(e1)
	--attach token
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(s.attcon)
	e2:SetTarget(s.atttg)
	e2:SetOperation(s.attop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCondition(s.attcon2)
	e3:SetTarget(s.atttg2)
	e3:SetOperation(s.attop2)
	c:RegisterEffect(e3)
	--attach xyz
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCode(id)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(s.xattcon)
	e4:SetOperation(s.xattop)
	c:RegisterEffect(e4)
	--leave
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetOperation(s.leaveop)
	c:RegisterEffect(e5)
end

--attach token
function s.confil(c,p)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsPreviousControler(p)
end
function s.attcon(e,tp,eg,ep,ev,re,r,rp)
	if re~=nil then if re:GetHandlerPlayer()~=tp then return false else return true end end
	if eg:Filter(s.confil,nil,tp):GetCount()>1 then return false end
	return eg:IsExists(s.confil,1,nil,tp,rp)
end
function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tfil,tp,LOCATION_MZONE,0,1,nil)
		and eg:GetFirst():IsPreviousLocation(LOCATION_MZONE) end
end
function s.attop(e,tp,eg,ep,ev,re,r,rp)
	local tok=Duel.GetMatchingGroup(s.tfil,tp,LOCATION_MZONE,0,nil):GetFirst()
	local gdes=eg:Filter(s.confil,nil,tp)
	if e:GetHandler():IsRelateToEffect(e) and #gdes>0 and tok then
		Duel.Overlay(tok,gdes)
		Duel.RaiseEvent(tok,id,e,0,0,0,0)
	end
end
function s.tfil(c)
	return c:IsCode(id+1) and c:IsFaceup()
end
function s.attcon2(e,tp,eg,ep,ev,re,r,rp)
	return s.attcon(e,1-tp,eg,ep,ev,re,r,rp)
end
function s.atttg2(e,tp,eg,ep,ev,re,r,rp,chk)
	return s.atttg(e,1-tp,eg,ep,ev,re,r,rp,chk)
end
function s.attop2(e,tp,eg,ep,ev,re,r,rp)
	return s.attop(e,1-tp,eg,ep,ev,re,r,rp)
end

--tokens
function s.tokcheck(e)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
	and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,0,0,0,0,0)
	and Duel.IsPlayerCanSpecialSummonMonster(1-tp,id+1,0,TYPES_TOKEN,0,0,0,0,0)
end
function s.toktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return s.tokcheck end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
function s.tokop(e,tp,eg,ep,ev,re,r,rp)
	c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if s.tokcheck then
		local sToken=Duel.CreateToken(tp,id+1)
		local oToken=Duel.CreateToken(1-tp,id+1)
		Duel.SpecialSummonStep(sToken,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		Duel.SpecialSummonStep(oToken,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
		Duel.SpecialSummonComplete()
		--immune
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(s.immfil)
		e1:SetReset(RESET_EVENT+0x47c0000)
		oToken:RegisterEffect(e1,true)
		--cannot be battle target
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
		e2:SetValue(aux.imval1)
		e2:SetReset(RESET_EVENT+0x47c0000)
		oToken:RegisterEffect(e2,true)
		--direct attack
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_DIRECT_ATTACK)
		e3:SetRange(LOCATION_MZONE)
		e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		e3:SetTarget(s.dirtg)
		e3:SetReset(RESET_EVENT+0x47c0000)
		oToken:RegisterEffect(e3,true)
		--cannot be tributed
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_UNRELEASABLE_SUM)
		e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e4:SetValue(1)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		oToken:RegisterEffect(e4)
		local e5=e4:Clone()
		e5:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		oToken:RegisterEffect(e5)
		--no type/attribute/level
		local e6=Effect.CreateEffect(c)
		e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e6:SetType(EFFECT_TYPE_SINGLE)
		e6:SetCode(EFFECT_CHANGE_RACE)
		e6:SetValue(0)
		oToken:RegisterEffect(e6)
		local e7=Effect.CreateEffect(c)
		e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e7:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		oToken:RegisterEffect(e7)
		oToken:SetStatus(STATUS_NO_LEVEL,true)
		--cannot change battle pos
		local e8=Effect.CreateEffect(c)
		e8:SetType(EFFECT_TYPE_SINGLE)
		e8:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e8:SetReset(RESET_EVENT+RESETS_STANDARD)
		oToken:RegisterEffect(e8)
		--clone
		local e9=e1:Clone()
		sToken:RegisterEffect(e9,true)
		local e10=e2:Clone()
		sToken:RegisterEffect(e10,true)
		local e11=e3:Clone()
		sToken:RegisterEffect(e11,true)
		local e12=e4:Clone()
		sToken:RegisterEffect(e12,true)
		local e13=e5:Clone()
		sToken:RegisterEffect(e13,true)
		local e14=e6:Clone()
		sToken:RegisterEffect(e14,true)
		local e15=e7:Clone()
		sToken:RegisterEffect(e15,true)
		local e16=e8:Clone()
		sToken:RegisterEffect(e16,true)
		sToken:SetStatus(STATUS_NO_LEVEL,true)
	end
end
function s.dirtg(e,c)
	return not Duel.IsExistingMatchingCard(s.dirfil,c:GetControler(),0,LOCATION_MZONE,1,nil)
end
function s.dirfil(c)
	return not c:IsCode(id+1)
end
function s.immfil(e,te)
	return not te:GetOwner():IsCode(id)
end

--attach xyz
function s.xattcon(e,tp,eg,ep,ev,re,r,rp)
	local tok1=Duel.GetMatchingGroup(s.tfil,tp,LOCATION_MZONE,0,nil):GetFirst()
	local tct1=tok1:GetOverlayGroup():GetCount()
	local tok2=Duel.GetMatchingGroup(s.tfil,1-tp,LOCATION_MZONE,0,nil):GetFirst()
	local tct2=tok2:GetOverlayGroup():GetCount()
	if tct1>2 then
		e:SetLabelObject(tok1)
		return true end
	if tct2>2 then
		e:SetLabelObject(tok2)
		return true end
	return false
end
function s.xattop(e,tp,eg,ep,ev,re,r,rp)
	if not c:IsRelateToEffect(e) then return end
	local tok=e:GetLabelObject()
	local rp=tok:GetControler()
	local c=Duel.GetMatchingGroup(s.tfil,rp,LOCATION_MZONE,0,nil):GetFirst()
	local cp=c:GetControler()
	if Duel.IsExistingMatchingCard(s.xyzfil,cp,LOCATION_MZONE,0,1,nil) then
		local xg=Duel.GetMatchingGroup(s.xyzfil,cp,LOCATION_MZONE,0,nil)
		if #xg==0 then return end
		local og=c:GetOverlayGroup()
		local ogct=#og
		while ogct>0 do
			Duel.Hint(HINT_SELECTMSG,cp,HINTMSG_TARGET)
			local xtg=xg:Select(cp,1,1,nil)
			Duel.Hint(HINT_SELECTMSG,cp,HINTMSG_TARGET)
			local sog=0
			if #xg<2 then
				sog=og:Select(cp,ogct,ogct,nil)
			else
				sog=og:Select(cp,1,ogct,nil)
			end
			local xtgc=xtg:GetFirst()
			Duel.Overlay(xtgc,sog)
			Duel.RaiseSingleEvent(c,EVENT_DETACH_MATERIAL,e,0,0,0,0)
			ogct=ogct-#sog
			local sogc=sog:GetFirst()
			while sogc do
				og:RemoveCard(sogc)
				sogc=sog:GetNext()
			end
		end
	end
	local cb=Duel.GetMatchingGroup(s.cbfil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.Destroy(cb,REASON_EFFECT)
end
function s.cbfil(c)
	return c:IsCode(id) and c:IsFaceup()
end
function s.xyzfil(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end

--leave
function s.leaveop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsFacedown() then return end
	local tg=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,LOCATION_MZONE,nil,id+1)
	local tc=tg:GetFirst()
	while tc do
		local og=tc:GetOverlayGroup()
		Duel.SendtoGrave(og,REASON_DESTROY)
		tc=tg:GetNext()
	end
	Duel.Destroy(tg,REASON_EFFECT)
end