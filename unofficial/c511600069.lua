--進化の繭 (Anime)
--Cocoon of Evolution (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--equip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40240595,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetRange(LOCATION_HAND)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCondition(s.checkcon)
	e2:SetOperation(s.checkop)
	e2:SetCountLimit(1)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_ADJUST)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCondition(s.checkcon2)
	e3:SetOperation(s.checkop2)
	c:RegisterEffect(e3)
	--equip effect
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_SET_BASE_ATTACK)
	e4:SetValue(c:GetAttack())
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_SET_BASE_DEFENSE)
	e5:SetValue(c:GetDefense())
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetCode(EFFECT_CANNOT_SSET)
	e6:SetRange(LOCATION_SZONE)
	e6:SetTargetRange(1,0)
	e6:SetTarget(aux.TRUE)
	e6:SetCondition(function(e) return e:GetHandler():GetCardTarget():IsExists(s.eqfilter,1,nil) end)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EFFECT_CANNOT_MSET)
	c:RegisterEffect(e7)
	local e8=e6:Clone()
	e8:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e8)
	local e9=e6:Clone()
	e9:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	c:RegisterEffect(e9)
	local e10=e6:Clone()
	e10:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e10)
	local e11=e6:Clone()
	e11:SetValue(s.aclimit)
	c:RegisterEffect(e11)
	--destroy
	local e12=Effect.CreateEffect(c)
	e12:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e12:SetRange(LOCATION_SZONE)
	e12:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e12:SetCountLimit(1)
	e12:SetCondition(s.descon)
	e12:SetOperation(s.desop)
	c:RegisterEffect(e12)
	--spsummon
	local e13=Effect.CreateEffect(c)
	e13:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e13:SetCode(EVENT_TO_GRAVE)
	e13:SetOperation(s.spop)
	c:RegisterEffect(e13)
	local e14=Effect.CreateEffect(c)
	e14:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e14:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e14:SetCode(EVENT_ADJUST)
	e14:SetRange(LOCATION_SZONE)
	e14:SetLabelObject(e13)
	e14:SetOperation(s.op)
	c:RegisterEffect(e14)
	local e15=e4:Clone()
	e15:SetCode(EFFECT_CHANGE_CODE)
	e15:SetValue(40240595)
	c:RegisterEffect(e15)
end
function s.filter(c)
	return c:IsFaceup() and c:IsCode(58192742,87756343)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if not tc or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	Duel.Equip(tp,c,tc,true)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetValue(s.eqlimit)
	e1:SetLabelObject(tc)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
function s.op(e,tp,eg,ev,ep,re,r,rp)
	e:GetLabelObject():SetLabel(e:GetHandler():GetTurnCounter())
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_LOST_TARGET) and c:GetPreviousEquipTarget():IsReason(REASON_DESTROY) then
		local ct=e:GetLabel()
		local code=ct>=5 and 48579379 or ct>=3 and 511002501 or ct>=1 and 511002500 or 0
		local atk=code==48579379 and 3500 or code==511002501 and 2600 or 500
		local def=code==48579379 and 3000 or code==511002501 and 2500 or 400
		local lv=(code==48579379 or code==511002501) and 8 or 2
		local typ=code==(48579379 or code==511002501) and TYPE_MONSTER+TYPE_EFFECT+TYPE_SPSUMMON or TYPE_MONSTER+TYPE_NORMAL
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and code~=0
			and Duel.IsPlayerCanSpecialSummonMonster(tp,code,0,typ,atk,def,lv,RACE_INSECT,ATTRIBUTE_EARTH) then
			local sc=Duel.CreateToken(tp,code)
			Duel.SpecialSummon(sc,0,tp,tp,true,true,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
	e:Reset()
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and e:GetHandler():GetTurnCounter()>=6
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if ec:IsFaceup() then
		if Duel.Destroy(ec,REASON_EFFECT)~=0 then
		else Duel.Destroy(c,REASON_EFFECT) end
	end
end
function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:GetHandler():IsLocation(LOCATION_HAND)
end
function s.eqfilter(c)
	local code=c:GetOriginalCode()
	return code==58192742 or code==87756343
end
function s.checkcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetCardTarget()
	return Duel.GetTurnPlayer()==tp and g and g:IsExists(s.eqfilter,1,nil)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()+1
	c:SetTurnCounter(ct)
end
function s.checkcon2(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetCardTarget()
	local g2=e:GetLabelObject() or Group.CreateGroup()
	return #g>0 and not g:Equal(g2)
end
function s.checkop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetCardTarget()
	local g2=e:GetLabelObject()
	if not g:IsExists(s.eqfilter,1,g:Filter(aux.TRUE,g2)) then
		c:SetTurnCounter(0)
	end
	g:KeepAlive()
	e:SetLabelObject(g)
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
